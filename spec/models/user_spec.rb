require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe 'サインイン' do
    context 'サインインできる' do
      it 'nickname,email,password,password_confirmationが存在する' do
        expect(@user).to be_valid
      end
    end

    context 'サインインできない' do
      it 'passwordが空ではできない' do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Password can't be blank")
      end
      it 'passwordが5文字以下ではできない' do
        @user.password = '12345'
        @user.password_confirmation = '12345'
        @user.valid?
        expect(@user.errors.full_messages).to include("Password is too short (minimum is 6 characters)")
      end
      it 'passwordとpassword_confirmationが不一致ではできない' do
        @user.password = '123456'
        @user.password_confirmation = '1234567'
        @user.valid?
        expect(@user.errors.full_messages).to include("Password confirmation doesn't match Password")
      end
    end
  end

  describe 'ログイン' do
    context 'ログインできる' do
      it '正しいemailとpasswordが入力されたとき' do
        @user.save
        expect(@user).to be_valid
      end
    end

    context 'ログインできない' do
      it '存在しないemailが入力されたとき' do
        expect(User.authenticate('nonexistent@example.com', @user.password)).to be_nil
      end
      it '誤ったpasswordが入力されたとき' do
        @user.save
        expect(User.authenticate(@user.email, 'wrong_password')).to be_nil
      end
    end
  end

  describe 'ユーザー情報編集' do
    context 'ユーザ情報が編集できる' do
      it 'nicknameが変更されたとき' do
        @user.save
        new_nickname = 'new_nickname'
        @user.update(nickname: new_nickname)
        expect(@user.reload.nickname).to eq(new_nickname)
      end
      it 'emailが更新されたとき'do
      @user.save
      new_email = 'new_email@example.com'
      @user.update(email: new_email)
      expect(@user.reload.email).to eq(new_email)
      end
    end

      context 'プロフィールが更新できない' do
      it 'emailが重複しているとき' do
        another_user = FactoryBot.create(:user)
        @user.save
        @user.update(email: another_user.email)
        expect(@user.errors.full_messages).to include('Email has already been taken')
      end
      it 'nicknameが空のとき' do
        @user.nickname = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Nickname can't be blank")
      end
      it 'emailが空のとき' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("Email can't be blank")
      end
    end
  end
end