require 'rails_helper'

RSpec.describe Image, type: :model do
  describe '#random_string' do
    before(:all) do
      @image = Image.new
    end

    it 'должно генерировать значение размером 20 символов (10 hex байтов)' do
      expect(@image.random_string.length).to eq(20)
    end

    it 'должно генерировать для одного экземпляра одно значение' do
      first_string = @image.random_string
      expect(@image.random_string).to eq(first_string)
    end

    it 'должно генерировать для разных экземпляров разные значения' do
      @image2 = Image.new
      first_string = @image2.random_string
      expect(@image.random_string).to_not eq(first_string)
    end
  end
end
