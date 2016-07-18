require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  describe '#tags' do
    before(:each) do
      FactoryGirl.create(:tag, :name => 'Tag 1')
      FactoryGirl.create(:tag, :name => 'Tag 2')
      FactoryGirl.create(:tag, :name => 'Tag 3')
      FactoryGirl.create(:tag, :name => 'Abc 3')
    end

    context 'без параметров' do
      it 'должен возвращать все тэги' do
        get :index
        expect(response.body).to include('Tag 1')
        expect(response.body).to include('Tag 2')
        expect(response.body).to include('Tag 3')
        expect(response.body).to include('Abc 3')
      end
    end

    context 'с параметром' do
      it 'должен возвращать только нужные тэги' do
        get :index, :term => 'Ab'
        expect(response.body).to_not include('Tag 1')
        expect(response.body).to_not include('Tag 2')
        expect(response.body).to_not include('Tag 3')
        expect(response.body).to include('Abc 3')
      end
    end
  end
end
