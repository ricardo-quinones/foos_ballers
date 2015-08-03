require 'spec_helper'

describe Api::V1::SessionsController, type: :controller do
  describe "POST create" do
    let!(:player) { create(:player) }

    context 'a valid login attempt' do
      before do
        login_params = {
          email:    player.email,
          password: 'password'
        }

        post :create, login_params
      end

      subject { response }
      its(:status) { is_expected.to eq(201) }
    end

    context 'a bad login attempt' do
      context 'the wrong password' do
        before do
          login_params = {
            email:    player.email,
            password: 'pass'
          }

          post :create, login_params
        end

        context 'the response' do
          subject { response }
          its(:status) { is_expected.to eq(401) } # unauthorized
        end

        context 'the body of the response' do
          subject { JSON.parse(response.body).with_indifferent_access }
          its([:developer_error]) { is_expected.to eq('Invalid credentials') }
          its([:messages]) { is_expected.to contain_exactly("Sorry, couldn't log you in with those credentials") }
        end
      end

      context 'an unrecognized email' do
        before do
          login_params = {
            email:    'lkajsdljaljasl@skjdf.com',
            password: 'password'
          }

          post :create, login_params
        end

        context 'the response' do
          subject { response }
          its(:status) { is_expected.to eq(404) }
        end

        context 'the body of the response' do
          let(:error) { ApiErrors::EmailNotFoundError.new }

          subject { JSON.parse(response.body).with_indifferent_access }
          its([:developer_error]) { is_expected.to eq(error.developer_error) }
          its([:messages]) { is_expected.to eq(error.messages) }
        end
      end
    end
  end

  describe "DELETE destroy" do
    it "changes the the auth token of the player" do
      player = create(:player)
      original_auth_token = player.encrypted_auth_token
      request.headers['HTTP_AUTHORIZATION'] = original_auth_token
      delete :destroy
      expect(response.status).to eq(202)
      expect(player.reload.encrypted_auth_token).to_not eq(original_auth_token)
    end
  end
end
