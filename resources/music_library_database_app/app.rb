# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/' do
    return erb(:home)
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    
    return erb(:albums)
  end

  get '/albums/new' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:new_album)
  end

  post '/albums' do
    @album_name = params[:title]
    @album_release_year = params[:release_year]
    @album_artist = params[:artist]

    if invalid_request_parameters?
      status 400
      return ''
    end

    repo_artist = ArtistRepository.new
    artists = repo_artist.all
    artists.each do |artist|
      if artist.name == @album_artist
        @album_artist_id = artist.id 
      end
    end

    repo = AlbumRepository.new
    new_album = Album.new
    new_album.title = @album_name
    new_album.release_year = @album_release_year
    new_album.artist_id = @album_artist_id 

    repo.create(new_album)
    return erb(:album_created)
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all

    return erb(:artists)
  end

  get '/artists/new' do
    return erb(:new_artist)
  
  end

  post '/artists' do 
    @artist_name = params[:name]
    @artist_genre = params[:genre]

    if invalid_request_parameters_artist?
      status 400
      return ''
    end

    repo = ArtistRepository.new
    new_artist = Artist.new
    new_artist.name = @artist_name
    new_artist.genre = @artist_genre
    repo.create(new_artist)
    
    return erb(:artist_created)
  end

  get '/albums/:id' do
    album_repo = AlbumRepository.new
    artist_repo = ArtistRepository.new
    id = params[:id]
    @album = album_repo.find(id)
    artist_id = @album.artist_id
    @artist = artist_repo.find(artist_id)

    return erb(:index)
  end

  get '/artists/:id' do
    repo = ArtistRepository.new
    @artist = repo.find(params[:id])
    return erb(:artist)
  end

  private

  def invalid_request_parameters?
    return (@album_name  == "" || @album_release_year == "" || @album_artist == "")
  end  

  def invalid_request_parameters_artist?
    return (@artist_name  == "" || @artist_genre == "")
  end  
end
