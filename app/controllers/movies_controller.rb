class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    session[:sort] = params[:sort] if params[:sort]
    session[:ratings] = params[:ratings] if params[:ratings]

    params[:sort] ||= session[:sort]
    params[:ratings] ||= session[:ratings]

    @ratings_to_show = params[:ratings] ? params[:ratings].keys  : (session[:ratings] ? [] : Movie.all_ratings )
    @movies = Movie.with_ratings(@ratings_to_show).order(params[:sort])
    @highlight_column = params[:sort]

    if params[:ratings].present?
      redirect_to(movies_path(ratings: params[:ratings]))
    elsif params[:sort].present?
      redirect_to(movies_path(sort: params[:sort]))
    elsif params[:ratings].blank? && session[:ratings].blank?
      render :index
    end

    # params[:sort] != nil ? (session[:sort] = params[:sort]) : (params[:sort] = session[:sort])
    # params[:ratings] != nil ? (session[:ratings] = params[:ratings]) : (params[:ratings] = session[:ratings])
    # @ratings_to_show = params[:ratings] == nil ? (session[:ratings] == nil ? Movie.all_ratings : [] ) : params[:ratings].keys
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
