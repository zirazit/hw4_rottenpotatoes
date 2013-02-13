require 'spec_helper'

describe MoviesController do
  describe 'searching similar' do
    fixtures :movies
    before :each do
      @fake_movie = movies(:star_wars_movie)
      @fake_sad_movie = movies(:alien_movie)
      @fake_results = [movies(:star_wars_movie), movies(:thx_1138_movie)]
    end
    it 'should call the model method that performs search movies with same director' do
      Movie.should_receive(:similar_directors).with(@fake_movie.director).
        and_return(@fake_results)
      post :search_similar, {:id => @fake_movie.id}
    end
    describe 'after valid search' do
      before :each do
        post :search_similar, {:id => @fake_movie.id}
      end
      it 'should select the Search Similar Results template for rendering' do
        response.should render_template('search_similar')
      end
      it 'should make the search similar results available to that template' do
        assigns(:movies).should == @fake_results
      end
    end
    describe 'for sad path where there is no director info for current movie' do
      it 'should return to the home page' do
        post :search_similar, {:id => @fake_sad_movie.id}
        response.should redirect_to movies_path
      end
    end
  end

  describe 'show' do
    fixtures :movies
    before :each do
      @fake_movie = movies(:star_wars_movie)
      @fake_sad_movie = movies(:alien_movie)
      @fake_results = [movies(:star_wars_movie), movies(:thx_1138_movie)]
    end
    it 'should call the model method that performs search movies with id' do
      Movie.should_receive(:find).with(@fake_movie.id).
        and_return(@fake_movie)
      id = @fake_movie.id
      post :show, {:id => id}
    end
  end

  describe 'new' do
    it 'it should  select the new movie template for rendering' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'create' do
    it 'should call the model method performe create!' do
      Movie.should_receive(:create!).with({"title" => 'Milk', "rating" => 'R'})
        .and_return(stub_model(Movie))
      post :create, :movie => {:title => 'Milk', :rating => 'R'}
    end
    it 'should redirected to movies path after create new object' do
      post :create, :movie => {:title => 'Milk', :rating => 'R'}
      response.should redirect_to movies_path
    end
  end

  describe 'edit' do
    fixtures :movies
    before :each do
      @fake_movie = movies(:star_wars_movie)
    end
    it 'should make the movie avaliabe to the template' do
      get :edit, :id => @fake_movie.id
      assigns[:movie].should == @fake_movie
    end
  end

  describe 'update' do
    fixtures :movies
    before :each do
      @fake_movie = movies(:star_wars_movie)
    end
    it 'should retrive the right movie from Movie model to update' do
      Movie.should_receive(:find).with(@fake_movie.id.to_s).and_return(@fake_movie)
      put :update, :id => @fake_movie.id, :movie => {:rating => @fake_movie.rating}
    end

    it 'should prepare the movie object avaliable for update' do
      put :update, :id => @fake_movie.id, :movie => {:rating => @fake_movie.rating}
      assigns(:movie).should == @fake_movie
    end

    it 'should pass movie object the new attribute value to updated' do
      fake_new_rating = 'PG-15'
      Movie.stub(:find).and_return(@fake_movie)
      @fake_movie.should_receive(:update_attributes!).with("rating" => fake_new_rating).and_return(:true)
      put :update, :id => @fake_movie.id, :movie => {:rating => fake_new_rating}
    end
  end

  describe 'index' do
    fixtures :movies
    before :each do
      @star_wars = movies(:star_wars_movie)
      @thx = movies(:thx_1138_movie)
    end
    it 'should select the index movie template for rendering' do
      post :index
      response.should render_template('index')
    end
    it "should sort by 'title' when :sort is 'title'" do
      session[:sort] = 'title'
      Movie.should_receive(:find_all_by_rating).
        with(anything(), {:order => :title})
      post :index, :sort => 'title'
    end
    it "should sort by 'release_date' when :sort is 'release_date'" do
      session[:sort] = 'release_date'
      Movie.should_receive(:find_all_by_rating).
        with(anything(), {:order => :release_date})
      post :index, :sort => 'release_date'
    end
    it 'should save new sort parameter in session and reset the query' do
      session[:sort] = 'title'
      post :index, :sort => 'release_date'
      session[:sort].should == 'release_date'
    end
    it 'should save and reset new rating query variable when new rating parameter received' do
      session[:ratings] = 'R'
      post :index, :ratings => 'PG'
      session[:ratings].should == 'PG'
    end
  end
  describe 'destroy' do
    fixtures :movies
    before :each do
      @star_wars_movie = movies(:star_wars_movie)
    end
    it 'should remove selected movie from collection' do
      Movie.stub(:find).and_return(@star_wars_movie)
      @star_wars_movie.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @star_wars_movie.id
    end
  end
end
