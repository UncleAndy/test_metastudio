require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
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
        post :create, { :user_id => @user.id, :image => {} }
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
        put :update, { :user_id => @user.id, :id => 1, :image => {} }
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
        post :create, { :user_id => @user.id, :image => {} }
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
        put :update, { :user_id => @user.id, :id => 1, :image => {} }
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

      @file = fixture_file_upload('/test.jpg', 'image/jpeg')
      @md5sum_file = 'a7b1c0c74d81da66d60395b57092e94c'
      @image = FactoryGirl.create(:image, :location => @file, :title => 'Test image')
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
          post :create, { :user_id => @user.id, :image => { :title => 'Image test', :location => @file} }
        }.to change(Image, :count).by(1)
      end

      it "должен делать перенаправление на список ссылок" do
        post :create, { :user_id => @user.id, :image => { :title => 'Image test', :location => @file} }
        expect(response).to redirect_to(user_images_path(@user.id))
      end
    end

    describe "#edit" do
      it "должен возвращать страницу редактирования" do
        get :edit, { :user_id => @user.id, :id => @image.id }
        expect(response).to be_success
      end
    end

    describe "#update" do
      before(:each) do
        @tag1 = FactoryGirl.create(:tag, :name => 'Tag 1')
        @tag2 = FactoryGirl.create(:tag, :name => 'Tag 2')
        @tag3 = FactoryGirl.create(:tag, :name => 'Tag 3')
        @tag4 = FactoryGirl.create(:tag, :name => 'Abc 3')
      end

      it "должен менять данные записи" do
        put :update, { :user_id => @user.id, :id => @image.id, :image => {:title => 'New image name'}}
        @image.reload
        expect(@image.title).to eq('New image name')
      end

      it "должен делать перенаправление на список ссылок" do
        put :update, { :user_id => @user.id, :id => @image.id, :image => {:title => 'New image name'}}
        expect(response).to redirect_to(user_images_path(@user.id))
      end

      it 'должен правильно сохранять список тэгов при создании' do
        put :update, { :user_id => @user.id, :id => @image.id, :image => {:title => 'New image name', :tags => 'Tag 1,Tag 2,Tag 3'}}
        @image.reload
        expect(@image.tags.count).to eq(3)
        expect(@image.tags).to include(@tag1)
        expect(@image.tags).to include(@tag2)
        expect(@image.tags).to include(@tag3)
        expect(@image.tags).to_not include(@tag4)
      end

      it 'должен правильно сохранять список тэгов при удалении' do
        @image.tags << @tag1
        @image.tags << @tag2
        @image.tags << @tag3
        @image.tags << @tag4
        put :update, { :user_id => @user.id, :id => @image.id, :image => {:title => 'New image name', :tags => 'Tag 2,Tag 3'}}
        @image.reload
        expect(@image.tags.count).to eq(2)
        expect(@image.tags).to_not include(@tag1)
        expect(@image.tags).to include(@tag2)
        expect(@image.tags).to include(@tag3)
        expect(@image.tags).to_not include(@tag4)
      end

      it 'должен правильно сохранять список тэгов при добавлении' do
        @image.tags << @tag2
        @image.tags << @tag3
        put :update, { :user_id => @user.id, :id => @image.id, :image => {:title => 'New image name', :tags => 'Tag 1,Tag 2,Tag 3,Abc 3'}}
        @image.reload
        expect(@image.tags.count).to eq(4)
        expect(@image.tags).to include(@tag1)
        expect(@image.tags).to include(@tag2)
        expect(@image.tags).to include(@tag3)
        expect(@image.tags).to include(@tag4)
      end

      it 'должен создавать новые тэги если их еще нет' do
        @image.tags << @tag2
        @image.tags << @tag3
        put :update, { :user_id => @user.id, :id => @image.id, :image => {:title => 'New image name', :tags => 'Tag 5,Tag 6,Tag 7'}}
        @image.reload
        expect(@image.tags.count).to eq(3)
        expect(@image.tags).to_not include(@tag1)
        expect(@image.tags).to_not include(@tag2)
        expect(@image.tags).to_not include(@tag3)
        expect(@image.tags).to_not include(@tag4)
        expect(Tag.count).to eq(7)
      end
    end

    describe "#destroy" do
      it "должен удалять запись" do
        expect {
          delete :destroy, { :user_id => @user.id, :id => @image.id }
        }.to change(Image, :count).by(-1)
      end

      it "должен делать перенаправление на список ссылок" do
        delete :destroy, { :user_id => @user.id, :id => @image.id }
        expect(response).to redirect_to(user_images_path(@user.id))
      end
    end

    describe '#plupload' do
      context 'без использования chunks' do
        it 'должен создавать новую картинку' do
          expect {
            post :plupload, { :user_id => @user.id, :file => @file, :name => 'Plupload file name.jpg' }
          }.to change(Image, :count).by(1)
        end
      end

      context 'с использованием chunks' do
        before(:each) do
          @chunk0 = fixture_file_upload('/test_chunk0', 'application/octet-stream')
          @chunk1 = fixture_file_upload('/test_chunk1', 'application/octet-stream')
          @chunk2 = fixture_file_upload('/test_chunk2', 'application/octet-stream')

          @assembled_file = Tempfile.new('chunked_file')
          allow(Tempfile).to receive(:new).and_return(Tempfile.new('any'))
          allow(Tempfile).to receive(:new).with('chunk').and_return(@assembled_file)
        end

        it 'должен создавать новую картинку' do
          expect {
            post :plupload, { chunk: 0, chunks: 3, :user_id => @user.id, :file => @chunk0, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 1, chunks: 3, :user_id => @user.id, :file => @chunk1, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 2, chunks: 3, :user_id => @user.id, :file => @chunk2, :name => 'Plupload file name.jpg' }
          }.to change(Image, :count).by(1)
        end

        context 'при прямом порядке chunks' do
          it 'должен создавать правильный файл' do
            post :plupload, { chunk: 0, chunks: 3, :user_id => @user.id, :file => @chunk0, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 1, chunks: 3, :user_id => @user.id, :file => @chunk1, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 2, chunks: 3, :user_id => @user.id, :file => @chunk2, :name => 'Plupload file name.jpg' }
            @assembled_file.rewind
            assembled_md5sum = Digest::MD5.hexdigest(@assembled_file.read)
            expect(assembled_md5sum).to eq(@md5sum_file)
          end
        end

        context 'при обратном порядке chunks' do
          it 'должен создавать правильный файл' do
            post :plupload, { chunk: 2, chunks: 3, :user_id => @user.id, :file => @chunk2, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 1, chunks: 3, :user_id => @user.id, :file => @chunk1, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 0, chunks: 3, :user_id => @user.id, :file => @chunk0, :name => 'Plupload file name.jpg' }
            @assembled_file.rewind
            assembled_md5sum = Digest::MD5.hexdigest(@assembled_file.read)
            expect(assembled_md5sum).to eq(@md5sum_file)
          end
        end

        context 'при случайном порядке chunks' do
          it 'должен создавать правильный файл' do
            post :plupload, { chunk: 1, chunks: 3, :user_id => @user.id, :file => @chunk1, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 2, chunks: 3, :user_id => @user.id, :file => @chunk2, :name => 'Plupload file name.jpg' }
            post :plupload, { chunk: 0, chunks: 3, :user_id => @user.id, :file => @chunk0, :name => 'Plupload file name.jpg' }
            @assembled_file.rewind
            assembled_md5sum = Digest::MD5.hexdigest(@assembled_file.read)
            expect(assembled_md5sum).to eq(@md5sum_file)
          end
        end
      end
    end
  end
end
