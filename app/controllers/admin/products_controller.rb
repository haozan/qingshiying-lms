class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :refresh_og_image]

  def index
    @products = Product.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_product_path(@product), notice: 'Product was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: 'Product was successfully deleted.'
  end

  def refresh_og_image
    if @product.link_url.blank?
      redirect_to admin_product_path(@product), alert: 'Cannot refresh OG image: link_url is blank.'
      return
    end

    fetched_image = OgImageFetcherService.call(@product.link_url)

    if fetched_image.present?
      @product.update(og_url: fetched_image)
      redirect_to admin_product_path(@product), notice: 'OG image was successfully refreshed.'
    else
      redirect_to admin_product_path(@product), alert: 'Failed to fetch OG image from the link URL.'
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :subtitle, :og_url, :cover_image_url, :link_url, :launch_date)
  end
end
