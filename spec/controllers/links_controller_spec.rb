require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  render_views

  include Devise::TestHelpers

  before(:each) do
    @user = FactoryGirl.create(:user)
    @user_bad = FactoryGirl.create(:user)
  end

  context 'Если заходит гость' do
    describe "#index" do
      it "должен возвращать страницу" do
        get :index, { :user_id => @user.id }
        expect(response).to be_success
      end

      it "должен рендерить шаблон index" do
        get :index, { :user_id => @user.id }
        expect(response).to render_template('index')
      end

      it "должен содержать ссылку для логина" do
        get :index, { :user_id => @user.id }
        expect(response.body).to include(I18n.t('menu.login'))
      end
    end

    describe "#new" do
      it "должно быть перенаправление на страницу логина" do
        get :new, { :user_id => @user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#create" do
      it "должно быть перенаправление на страницу логина" do
        post :create, { :user_id => @user.id, :link => {} }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#edit" do
      it "должно быть перенаправление на страницу логина" do
        get :edit, { :user_id => @user.id, :id => 1 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#update" do
      it "должно быть перенаправление на страницу логина" do
        put :update, { :user_id => @user.id, :id => 1, :link => {} }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "#destroy" do
      it "должно быть перенаправление на страницу логина" do
        delete :destroy, { :user_id => @user.id, :id => 1 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context 'Если пользователь заходит в чужую коллекцию' do
    before(:each) do
      sign_in @user_bad
    end

    describe "#index" do
      it "должен возвращать страницу" do
        get :index, { :user_id => @user.id }
        expect(response).to be_success
      end

      it "должен рендерить шаблон index" do
        get :index, { :user_id => @user.id }
        expect(response).to render_template('index')
      end

      it "должен содержать ссылку для выхода" do
        get :index, { :user_id => @user.id }
        expect(response.body).to include(I18n.t('menu.logout'))
      end
    end

    describe "#new" do
      it "должен перенаправлять на главную с сообщением о нехватке прав" do
        get :new, { :user_id => @user.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('errors.no_user_permission'))
      end
    end

    describe "#create" do
      it "должен перенаправлять на главную с сообщением о нехватке прав" do
        post :create, { :user_id => @user.id, :link => {} }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('errors.no_user_permission'))
      end
    end

    describe "#edit" do
      it "должен перенаправлять на главную с сообщением о нехватке прав" do
        get :edit, { :user_id => @user.id, :id => 1 }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('errors.no_user_permission'))
      end
    end

    describe "#update" do
      it "должен перенаправлять на главную с сообщением о нехватке прав" do
        put :update, { :user_id => @user.id, :id => 1, :link => {} }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('errors.no_user_permission'))
      end
    end

    describe "#destroy" do
      it "должен перенаправлять на главную с сообщением о нехватке прав" do
        delete :destroy, { :user_id => @user.id, :id => 1 }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('errors.no_user_permission'))
      end
    end
  end

  context 'Если пользователь заходит в свою коллекцию' do
    before(:each) do
      sign_in @user

      @link = FactoryGirl.create(:link)
    end

    describe "#index" do
      it "должен возвращать страницу" do
        get :index, { :user_id => @user.id }
        expect(response).to be_success
      end

      it "должен рендерить шаблон index" do
        get :index, { :user_id => @user.id }
        expect(response).to render_template('index')
      end

      it "должен содержать ссылку для выхода" do
        get :index, { :user_id => @user.id }
        expect(response.body).to include(I18n.t('menu.logout'))
      end
    end

    describe "#new" do
      it "должен возвращать страницу новой ссылки" do
        get :new, { :user_id => @user.id }
        expect(response).to be_success
      end
    end

    describe "#create" do
      it "должен создавать новую запись" do
        expect {
          post :create, { :user_id => @user.id, :link => { :name => 'Link test', :url => 'http://test.ru/'} }
        }.to change(Link, :count).by(1)
      end

      it "должен делать перенаправление на список ссылок" do
        post :create, { :user_id => @user.id, :link => { :name => 'Link test', :url => 'http://test.ru/'} }
        expect(response).to redirect_to(user_links_path(@user.id))
      end
    end

    describe "#edit" do
      it "должен возвращать страницу редактирования" do
        get :edit, { :user_id => @user.id, :id => @link.id }
        expect(response).to be_success
      end
    end

    describe "#update" do
      it "должен менять данные записи" do
        put :update, { :user_id => @user.id, :id => @link.id, :link => {:name => 'New link name', :url => 'http://new.link.ru/'}}
        @link.reload
        expect(@link.name).to eq('New link name')
        expect(@link.url).to eq('http://new.link.ru/')
      end

      it "должен делать перенаправление на список ссылок" do
        put :update, { :user_id => @user.id, :id => @link.id, :link => {:name => 'New link name', :url => 'http://new.link.ru/'}}
        expect(response).to redirect_to(user_links_path(@user.id))
      end
    end

    describe "#destroy" do
      it "должен удалять запись" do
        expect {
          delete :destroy, { :user_id => @user.id, :id => @link.id }
        }.to change(Link, :count).by(-1)
      end

      it "должен делать перенаправление на список ссылок" do
        delete :destroy, { :user_id => @user.id, :id => @link.id }
        expect(response).to redirect_to(user_links_path(@user.id))
      end
    end
  end
end
