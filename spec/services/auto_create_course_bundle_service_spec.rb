require 'rails_helper'

RSpec.describe AutoCreateCourseBundleService, type: :service do
  # 清理seeds创建的数据
  before(:each) do
    CourseBundle.destroy_all
    CourseBundleItem.destroy_all
    Course.destroy_all
  end

  describe '#call' do
    context 'when all courses exist' do
      let!(:ai_course) { create(:course, name: 'AI课程') }
      let!(:writing_course) { create(:course, name: '写作运营课') }
      let!(:programming_course) { create(:course, name: 'AI编程课') }

      it 'creates the course bundle successfully' do
        service = AutoCreateCourseBundleService.new
        result = service.call

        expect(result[:success]).to be true
        expect(result[:message]).to include('套餐创建成功')
        
        bundle = CourseBundle.find_by(name: '3 课联报特惠')
        expect(bundle).to be_present
        expect(bundle.status).to eq('active')
        expect(bundle.original_price).to eq(30000.00)
        expect(bundle.current_price).to eq(15000.00)
        expect(bundle.early_bird_price).to eq(9000.00)
        expect(bundle.courses.count).to eq(3)
        expect(bundle.courses.pluck(:name)).to match_array(['AI课程', '写作运营课', 'AI编程课'])
      end

      it 'updates existing bundle if already exists' do
        existing_bundle = CourseBundle.create!(
          name: '3 课联报特惠',
          description: 'Old description',
          original_price: 10000,
          status: 'inactive'
        )

        service = AutoCreateCourseBundleService.new
        result = service.call

        expect(result[:success]).to be true
        
        existing_bundle.reload
        expect(existing_bundle.status).to eq('active')
        expect(existing_bundle.original_price).to eq(30000.00)
        expect(existing_bundle.courses.count).to eq(3)
      end
    end

    context 'when courses are missing' do
      it 'returns error when AI课程 is missing' do
        create(:course, name: '写作运营课')
        create(:course, name: 'AI编程课')

        service = AutoCreateCourseBundleService.new
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to include('缺少课程')
        expect(result[:message]).to include('AI课程')
      end

      it 'returns error when all courses are missing' do
        service = AutoCreateCourseBundleService.new
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to include('缺少课程')
        expect(result[:message]).to include('AI课程')
        expect(result[:message]).to include('写作运营课')
        expect(result[:message]).to include('AI编程课')
      end
    end
  end
end
