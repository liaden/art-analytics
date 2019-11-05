require 'rails_helper'

describe BootstrapFormBuilder do
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      create_table :test_resources, force: true do |t|
        t.string 'name'
        t.datetime 'started_at'
        t.integer 'counter'
        t.jsonb 'tags'
      end
    end
  end

  class TestResource < ActiveRecord::Base
  end

  let(:builder_options) { {} }
  let(:action_view) { ActionView::Base.with_view_paths(['app/views']) }
  let(:options) { {} }

  let(:builder) do
    BootstrapFormBuilder.new(TestResource.name, TestResource.new, action_view, builder_options)
  end

  describe '#group' do
    it { expect { builder.group }.to raise_error(ArgumentError) }

    context 'with block' do
      let(:block) { proc { 'abcd' } }

      subject(:text) { builder.group(options, &block) }

      it { is_expected.to have_tag('.form-group', text: 'abcd') }

      context 'nested group' do
        let(:block) { proc { builder.group { 'nested' } } }

        it { is_expected.to have_tag('.form-group', text: 'nested') }
        it { is_expected.to_not have_tag('.form-group > .form-group') }
      end
    end
  end

  describe '#row' do
    it { expect { builder.row }.to raise_error(ArgumentError) }

    context 'with block' do
      let(:block) { proc { 'abcd' } }

      subject(:text) { builder.row(&block) }

      it { is_expected.to have_tag('.form-row', text: 'abcd') }

      context 'nested' do
        let(:block) { proc { builder.row { 'nested' } } }

        it { is_expected.to have_tag('.form-row > .form-row', text: 'nested') }
      end
    end
  end

  describe '#input_group' do
    it { expect { builder.input_group }.to raise_error(ArgumentError) }

    subject(:text) { builder.input_group(&block) }

    context 'with block' do
      let(:block) { proc { 'abcd' } }

      it { is_expected.to have_tag('.input-group', text: 'abcd') }
    end
  end

  describe '#number_field' do
    subject(:text) { builder.number_field(:counter) }

    it { is_expected.to have_tag('input.form-control[type=\'number\']') }
    it { is_expected.to have_tag('.form-group > label', text: 'Counter') }
  end

  describe '#text_field' do
    subject(:text) { builder.text_field(:name, options) }

    it { is_expected.to have_tag('input.form-control[type=\'text\']') }
    it { is_expected.to have_tag('.form-group > label', text: 'Name') }

    context  'label is hidden' do
      before { options[:label] = { hidden: true } }

      it 'does not have a label tag nor label attribute' do
        is_expected.to_not include('label')
      end
    end
  end

  describe '#submit' do
    subject(:text) { builder.submit('Go Go Go') }

    it { is_expected.to have_tag('input.btn') }
    it { is_expected.to have_tag('input[value=\'Go Go Go\']') }
    it { is_expected.to have_tag('input[type=\'submit\']') }
  end

  describe '#button' do
    subject(:texst) { builder.button('Go Go Go') }

    it { is_expected.to have_tag('button.btn', text: 'Go Go Go') }
    it { is_expected.to have_tag('button[type=\'submit\']') }
  end
end
