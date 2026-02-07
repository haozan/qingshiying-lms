# Load Failed Error Fix

## Problem Description

When users clicked the "立即报名" (Enroll Now) button on the `/courses` page to purchase a course bundle, the browser console showed two "Load failed" errors:

```
Error 1: Load failed
Error 2: [console.error] Load failed
```

**Root Cause Analysis:**

The error occurred because of a combination of issues in the payment flow:

### Issue 1: Invalid Turbo Stream Template (422 Error)

The `app/views/payments/pay.turbo_stream.erb` file contained:

```erb
<turbo-stream action="redirect" url="<%= @checkout_url %>" data-turbo="false">
</turbo-stream>
```

**Problems:**
- Turbo Stream doesn't support `action="redirect"` as a standard action
- This caused Rails to return **422 Unprocessable Content** status
- The browser failed to parse this invalid turbo-stream response
- Result: "Load failed" errors in console

### Issue 2: Missing `data-turbo=false` on Purchase Buttons

The course bundle purchase buttons were missing the `data: { turbo: false }` attribute:

```erb
<!-- BEFORE (Broken) -->
<%= button_to purchase_course_bundle_path(@course_bundle), 
    method: :post, 
    class: "btn-primary" %>
```

**Problem:**
- Without `data: { turbo: false }`, Turbo intercepts the form submission
- Turbo tries to handle the external Stripe redirect as a Turbo request
- This causes navigation failures and "Load failed" errors

## Solution Implemented

### Fix 1: Remove Invalid Turbo Stream Template

**Deleted:** `app/views/payments/pay.turbo_stream.erb`

**Updated:** `app/controllers/payments_controller.rb`

```ruby
def pay
  stripe_service = StripePaymentService.new(@payment, request)
  result = stripe_service.call

  if result[:success]
    # Direct redirect to Stripe checkout page
    redirect_to result[:checkout_session].url, allow_other_host: true
  else
    flash[:alert] = "Payment initialization failed: #{result[:error]}"
    redirect_to root_path
  end
end
```

**Why this works:**
- Uses standard Rails `redirect_to` instead of invalid turbo-stream
- Returns proper 302 redirect status instead of 422 error
- Browser correctly follows the redirect to Stripe checkout

### Fix 2: Add `data-turbo=false` to Purchase Buttons

**Updated files:**
- `app/views/courses/index.html.erb` (line 254)
- `app/views/course_bundles/show.html.erb` (line 28)

```erb
<!-- AFTER (Fixed) -->
<%= button_to purchase_course_bundle_path(@course_bundle), 
    method: :post, 
    class: "btn-primary",
    data: { turbo: false } %>
```

**Why this works:**
- `data: { turbo: false }` tells Turbo to NOT intercept the form submission
- The form submits as a standard browser request
- Browser correctly handles the redirect to external Stripe URL
- No "Load failed" errors occur

## Verification

All tests pass after the fix:

```bash
bundle exec rspec spec/requests/courses_spec.rb \
  spec/requests/course_bundles_spec.rb \
  spec/requests/payment_integration_spec.rb

# Result: 9 examples, 0 failures ✅
```

## Key Lessons

1. **Never use non-standard Turbo Stream actions** - Only use: `append`, `prepend`, `replace`, `update`, `remove`, `before`, `after`
2. **Always add `data-turbo=false` for external redirects** - Especially for payment gateways like Stripe
3. **Check HTTP status codes** - 422 indicates a rendering/parsing error
4. **Turbo Stream should return 200 OK** - Not error status codes
5. **Use standard redirects for external URLs** - Don't try to force Turbo Stream for everything

## Testing the Fix

To manually test:

1. Visit `/courses` page
2. Click "立即报名" (Enroll Now) button
3. Should redirect to Stripe checkout WITHOUT console errors
4. Console should be clean (no "Load failed" errors)

## Related Files

- `app/controllers/course_bundles_controller.rb` - Course bundle purchase flow
- `app/controllers/payments_controller.rb` - Payment processing
- `app/views/courses/index.html.erb` - Course listing with bundle purchase
- `app/views/course_bundles/show.html.erb` - Bundle detail page
- `app/services/stripe_payment_service.rb` - Stripe integration

## Date Fixed

February 7, 2026
