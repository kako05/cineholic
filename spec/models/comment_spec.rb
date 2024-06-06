require 'rails_helper'

RSpec.describe Comment, type: :model do
  before do
    @comment = FactoryBot.create(:comment)
    @user = FactoryBot.create(:user)
    @film = FactoryBot.create(:film)
  end

  describe 'レビュー投稿' do
    context 'レビュー投稿できる' do
      it 'レビューが書いてあり、ユーザーと作品に紐づいていればできる' do
        expect(@comment).to be_valid
      end
    end

    context 'レビュー投稿できない' do
      it 'レビューがないとできない' do
        @comment.comment = ''
        @comment.valid?
        expect(@comment.errors.full_messages).to include("Comment can't be blank")
      end
      it 'ユーザに紐づいていないとできない' do
        @comment.user = nil
        @comment.valid?
        expect(@comment.errors.full_messages).to include("User must exist")
      end
      it '作品に紐づいていないとできない' do
        @comment.film = nil
        @comment.valid?
        expect(@comment.errors.full_messages).to include("Film must exist")
      end
    end
  end
end
