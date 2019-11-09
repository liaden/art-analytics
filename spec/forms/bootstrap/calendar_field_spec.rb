RSpec.describe Bootstrap::CalendarField, type: :view do
  class FakeControls
    include ActiveModel::Model
    include Virtus.model

    attribute :birth, Date
  end

  def form_html(&block)
    form_for(controls, url: '/fake', &block)
  end

  let(:controls) { FakeControls.new(control_attrs) }
  let(:control_attrs) { {} }

  subject(:rendered_form) { form_html { |f| f.calendar_field(:birth) } }

  it { is_expected.to have_tag('.form-group > label', count: 1) }

  it'has text field' do
    is_expected.to have_tag('.input-group > input[type=\'text\']')
  end

  it 'has appended button' do
    is_expected.to have_tag('.input-group > .input-group-append > .input-group-text')
  end

  it 'has calendar button' do
    is_expected.to have_tag('.input-group-text > a.flatpickr-toggle > i')
  end

  context 'with value' do
    before { controls.birth = Date.new(2019, 8, 31) }

    it { is_expected.to have_tag('input[value=\'2019-08-31\']') }
  end
end
