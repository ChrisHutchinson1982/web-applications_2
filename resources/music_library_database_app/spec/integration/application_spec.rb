require "spec_helper"
require "rack/test"
require_relative '../../app'

def reset_music_libary
  seed_sql = File.read('spec/seeds/music_library.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do

  before(:each) do
    reset_music_libary
  end
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "for GET /albums/:id" do
    it "returns info from album 1" do
      response = get("/albums/1")
      expect(response.body).to include('<h1>Doolittle</h1>')
      expect(response.body).to include('Release year: 1989')
      expect(response.body).to include('Artist: Pixies')
    end
    it "returns info from album 2" do
      response = get("/albums/2")
      expect(response.body).to include('<h1>Surfer Rosa</h1>')
      expect(response.body).to include('Release year: 1988')
      expect(response.body).to include('Artist: Pixies')
    end
  end

  context "GET /albums" do
    it "returns list of albums with dynamic link to /albums/:id" do
      response = get("/albums")
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Albums</h1>')
      expect(response.body).to include('<a href="/albums/1">Doolittle</a><br />')
      expect(response.body).to include('Released: 1989<br /><br />')
      expect(response.body).to include('<a href="/albums/12">Ring Ring</a>')
      expect(response.body).to include('Released: 1973<br /><br />')
    end
  end


  context "GET /artists/:id" do 
    it "returns info. from artist 1" do 
      response = get("/artists/1")
      expect(response.body).to include('<h1>Pixies</h1>')
      expect(response.body).to include('Genre: Rock')
    end
    it "returns info. from artist 1" do 
      response = get("/artists/2")
      expect(response.body).to include('<h1>ABBA</h1>')
      expect(response.body).to include('Genre: Pop')
    end
  end

  context "GET /artists" do 
    it "returns list of artists with dynamic link to /artist/:id" do
      response = get("/artists")
      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Artists</h1>')
      expect(response.body).to include('<a href="/artists/1">Pixies</a><br />')
      expect(response.body).to include('<a href="/artists/2">ABBA</a><br />')
      expect(response.body).to include('<a href="/artists/3">Taylor Swift</a><br />')
    end
  end

  context "GET /albums/new" do

    it 'returns the form page' do 
      response = get("/albums/new")

      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Add a Album</h1>')
      expect(response.body).to include('<form action="/albums" method="POST">') 
      expect(response.body).to include('<input type="text" name="title"><br /><br />') 
      expect(response.body).to include('<input type="text" name="release_year"><br /><br />') 
      expect(response.body).to include('<select name="artist"><br /><br />')
      expect(response.body).to include('<input type="submit">') 
      expect(response.body).to include('<option>Pixies</option>') 
      expect(response.body).to include('<option>ABBA</option>') 
    end
  end

  context "POST /albums" do

    it 'validates the parameters' do
      response = post("/albums", title: "", release_year: "", artist: "")
      expect(response.status).to eq(400)
    end

    it 'creates a new album and returns a confirmation page' do
      
      response = post("/albums", title: "Voyage", release_year: "2022", artist: "ABBA")
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You have saved Voyage</h1>')
     
      response = get("/albums")
      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/albums/13">Voyage</a>')
    end

    it 'creates a different new album and returns a confirmation page' do
      
      response = post("/albums", title: "Doggerel", release_year: "2022", artist: "Pixies")
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You have saved Doggerel</h1>')
     
      response = get("/albums")
      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/albums/13">Doggerel</a>')
    end
  end

  context "GET /artists/new" do

    it 'returns the form page' do 
      response = get("/artists/new")

      expect(response.status).to eq 200
      expect(response.body).to include('<h1>Add a Artist</h1>')
      expect(response.body).to include('<form action="/artists" method="POST">') 
      expect(response.body).to include('<input type="text" name="name"><br /><br />') 
      expect(response.body).to include('<input type="text" name="genre"><br /><br />') 
      expect(response.body).to include('<input type="submit">') 

    end
  end

  context "POST /artists" do

    it 'validates the parameters' do
      response = post("/artists", name: "", genre: "")
      expect(response.status).to eq(400)
    end

    it 'creates a new artist and returns a confirmation page' do
      
      response = post("/artists", name: "Radiohead", genre: "Alternative")
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You have saved Radiohead</h1>')
     
      response = get("/artists")
      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/artists/5">Radiohead</a>')
    end

   it 'creates a different new album and returns a confirmation page' do
      
      response = post("/artists", name: "Stormzy", genre: "Hip-Hop")
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>You have saved Stormzy</h1>')
     
      response = get("/artists")
      expect(response.status).to eq 200
      expect(response.body).to include('<a href="/artists/5">Stormzy</a>')
    end
  end


  # context "GET /albums" do
  #   it "returns list of album titles" do
  #     response = get("/albums")
  #     expected_response = "Baltimore, Bossanova, Doolittle, Fodder on My Wings, Folklore, Here Comes the Sun, I Put a Spell on You, Lover, Ring Ring, Super Trouper, Surfer Rosa, Waterloo"
  #     expect(response.status).to eq 200
  #     expect(response.body).to eq(expected_response)
  #   end
  # end

  # context "POST /albums" do
  #   it 'creates a new album' do
      
  #     response = post("/albums", title: "Voyage", release_year: "2022", artist_id: 2)
  #     expect(response.status).to eq(200)
  #     expect(response.body).to eq('')
     
  #     response = get("/albums")
  #     expect(response.status).to eq 200
  #     expect(response.body).to include("Voyage")
  #   end
  # end

  # context "POST /artists" do
  #   it 'creates a new artist' do 
  #     response = post("/artists", name: "Wild nothing", genre: "Indie")
  #     expect(response.status).to eq(200)
  #     expect(response.body).to eq ('')

  #     response = get("/artists")
  #     expected_response = "Pixies, ABBA, Taylor Swift, Nina Simone, Wild nothing"
  #     expect(response.status).to eq 200
  #     expect(response.body).to eq(expected_response)
  #   end
  # end
end