RSpec.describe Bootstrap::ToggleCollectionField, type: :view do
  class FakeControls
    include ActiveModel::Model
    include Virtus.model

    CAR_TYPE_OPTIONS = [:truck, :sedan, :minivan]

    attribute :car_type, Symbol, default: CAR_TYPE_OPTIONS.first
  end

  def form_html(&block)
    form_for(controls, url: '/fake', &block)
  end

  let(:controls) { FakeControls.new(control_attrs) }
  let(:control_attrs) { {} }

  subject(:rendered_form) { form_html { |f| f.toggle_field(:car_type) } }


  it { is_expected.to have_tag('.form-group > label') }
  it { is_expected.to have_tag('label > input[value=\'truck\']') }
  it { is_expected.to have_tag('label', text: 'Truck') }
  it { is_expected.to have_tag('.form-group > .btn-group-toggle') }
  it { is_expected.to have_tag('.form-group > .btn-group' ) }

  context 'with translations' do
    let(:extra_i18n) do
      data = { activemodel: { attributes: { 'fake_controls/car_type': {}} } }

      data[:activemodel][:attributes][:'fake_controls/car_type'] = {
        truck: 'F150',
        sedan: 'Ford Focus',
        minivan: 'Ford Transit Connect'
      }
      data.deep_stringify_keys!

      data
    end

    with_translations(:extra_i18n)

    it { is_expected.to have_tag('label', text: 'F150') }
  end
end
