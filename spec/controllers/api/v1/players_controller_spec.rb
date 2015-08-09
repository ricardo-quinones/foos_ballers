require 'spec_helper'

describe Api::V1::PlayersController, type: :controller do
  describe "POST create" do
    context 'a succesfully created user' do
      context 'with a password confirmation' do
        before do
          player_params = {
            name:                  'New Player',
            email:                 'email@example.com',
            password:              'password',
            password_confirmation: 'password'
          }

          post :create, player: player_params
        end

        context 'the response' do
          subject { response }
          its(:status) { is_expected.to eq(201) }
        end

        context 'the body of the resonse' do
          subject { JSON.parse(response.body).with_indifferent_access }
          its([:auth_token]) { is_expected.to be_present }
          its([:auth_token]) { is_expected.to be_a(String) }
        end
      end

      context 'with no password confirmation' do
        context 'with no email' do
          before do
            player_params = {
              name:                  'New Player',
              email:                 'email@example.com',
              password:              'password'
            }

            post :create, player: player_params
          end

          subject { response }
          its(:status) { is_expected.to eq(201) }
        end
      end
    end

    context 'a malformed request' do
      context 'with passwords that do not match' do
        before do
          player_params = {
            name:                  'New Player',
            email:                 'email@example.com',
            password:              'password',
            password_confirmation: 'pass'
          }

          post :create, player: player_params
        end

        context 'the response' do
          subject { response }
          its(:status) { is_expected.to eq(400) }
        end

        context 'the body of the response' do
          subject { JSON.parse(response.body).with_indifferent_access }
          its([:developer_error]) { is_expected.to be_present }
          its([:developer_error]) { is_expected.to be_a(String) }
          its([:messages])        { is_expected.to be_a(Array) }
          its([:messages])        { is_expected.to satisfy { |a| a.count == 1 } }
          its([:messages])        { is_expected.to contain_exactly("Password confirmation doesn't match Password") }
        end
      end

      context 'with a bad email' do
        before do
          player_params = {
            name:                  'New Player',
            email:                 'email',
            password:              'password',
            password_confirmation: 'password'
          }

          post :create, player: player_params
        end

        subject { JSON.parse(response.body).with_indifferent_access }
        its([:messages]) { is_expected.to satisfy { |a| a.count == 1 } }
        its([:messages]) { is_expected.to contain_exactly("Email is invalid") }
      end

      context 'with no email' do
        before do
          player_params = {
            name:                  'New Player',
            password:              'password',
            password_confirmation: 'password'
          }

          post :create, player: player_params
        end

        subject { JSON.parse(response.body).with_indifferent_access }
        its([:messages]) { is_expected.to satisfy { |a| a.count == 2 } }
        its([:messages]) { is_expected.to contain_exactly("Email can't be blank", "Email is invalid") }
      end

      context 'with no password' do
        before do
          player_params = {
            name:  'New Player',
            email: 'email@example.com',
          }

          post :create, player: player_params
        end

        subject { JSON.parse(response.body).with_indifferent_access }
        its([:messages]) { is_expected.to satisfy { |a| a.count == 1 } }
        its([:messages]) { is_expected.to contain_exactly("Password can't be blank") }
      end
    end
  end

  describe "GET autocomplete_player_name" do
    let!(:player) { create(:player) }

    context 'with no id filtering' do
      before { get :autocomplete_player_name, term: 'Manag' }

      context 'the body of the response' do
        subject { JSON.parse(response.body) }
        it         { is_expected.to be_a(Array) }
        its(:size) { is_expected.to eq(1) }
      end

      context 'the result' do
        subject { JSON.parse(response.body)[0].with_indifferent_access }
        its([:id])    { is_expected.to eq(player.id.to_s) }
        its([:label]) { is_expected.to eq(player.name) }
        its([:value]) { is_expected.to eq(player.name) }
      end
    end

    context 'with id filtering' do
      before { get :autocomplete_player_name, term: 'Manag', ids_not_in: [player.id] }

      subject { JSON.parse(response.body) }
      its(:size) { is_expected.to eq(0) }
    end
  end

  describe "GET first_unfinished_match" do
    let(:access_token) { player.api_keys.first.encrypted_access_token }

    before do
      request.headers['HTTP_AUTHORIZATION'] = access_token
      get :first_unfinished_match, id: player.id
    end

    context 'with an unfinished match' do
      let!(:match) { create(:match) }
      let(:player) { match.players.first }

      before { get :first_unfinished_match, id: player.id }

      context 'the response' do
        subject { response }
        its(:status) { is_expected.to eq(200) }
      end

      context 'the body of the response' do
        subject { JSON.parse(response.body).with_indifferent_access }
        its([:match]) { is_expected.not_to be_nil }
      end
    end

    context 'with no unfinished matches' do
      let(:player) { create(:player) }

      context 'the response' do
        subject { response }
        its(:status) { is_expected.to eq(200) }
      end

      context 'the body of the response' do
        subject { JSON.parse(response.body).with_indifferent_access }
        its([:match]) { is_expected.to be_nil }
      end
    end
  end
end
