FactoryGirl.define do
  factory :link do
    sequence(:name) { |n| "Link #{n}" }
    sequence(:url) { |n| "http://www.#{n}.ru/" }
  end
end
