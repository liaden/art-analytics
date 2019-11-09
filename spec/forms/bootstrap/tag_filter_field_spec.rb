RSpec.describe Bootstrap::TagFilterField, type: :view do
  class FakeControls
    include ActiveModel::Model
    include Virtus.model

    attribute :criteria,                TagFilter
    attribute :artwork_tag_filter,      TagFilter
    attribute :artwork_tag_filter_name, TagFilter
  end

  def form_html(&block)
    form_for(controls, url: '/fake', &block)
  end

  let(:controls) { FakeControls.new(control_attrs) }
  let(:control_attrs) { {} }
  let(:tag_filter) { TagFilter.new(tags: ['x','y']) }

  describe 'generic attribute name' do
    subject { form_html { |f| f.tag_filter_field(:criteria) } }

    it { is_expected.to have_tag('input[value=\'\']') }
    it { is_expected.to have_tag('input.form-control') }
    it { is_expected.to have_tag('div.form-group') }
    it { is_expected.to have_tag('input[data-resource!=\'\']') }

    context 'with a value' do
      let(:control_attrs) { { criteria: tag_filter } }

      it { is_expected.to include("value=\"x,y\"") }
    end
  end

  describe '#{resource}_tag_filter' do
    subject { form_html { |f| f.tag_filter_field(:artwork_tag_filter) } }

    it { is_expected.to have_tag('input[data-resource=\'artwork\']') }
  end

  describe '#{resource}_tag_filter_#{suffix}' do
    subject { form_html { |f| f.tag_filter_field(:artwork_tag_filter_name) } }

    it { is_expected.to have_tag('input[data-resource=\'artwork\']') }
  end
end
