require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  
  test "login with invalid information" do

    #1.ログイン用のパスを開く
    get login_path

    #2.新しいセッションのフォームが正しく表示されたことを確認する
    assert_template 'sessions/new'

    #3.わざと無効なparamsハッシュを使用してセッション用パスにPOSTする
    post login_path, session: { email: "", password: "" }

    #4.新しいセッションのフォームが再度表示され、フラッシュメッセージが追加されることを確認する
    assert_template 'sessions/new'
    assert_not flash.empty?

    #5.別のページ (Homeページなど) にいったん移動する
    get root_path

    #6.移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end
  
  test "login with valid information" do
    #1.ログイン用のパスを開く
    get login_path
    
    #3.paramsハッシュを使用してセッション用パスにPOSTする
    post login_path, session: { email: @user.email, password: 'password' }
    
    #ユーザ画面が表示
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    
    #リンク先が正しいか確認
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token'] #文字列キーならcookiesで使用可
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token'] #文字列キーならcookiesで使用可
  end
end
