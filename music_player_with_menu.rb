require './input_functions'

module Genre
    POP, CLASSIC, JAZZ, ROCK = *1..4
end
  $genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']
  
  class Album
      attr_accessor :title, :artist, :genre, :year, :tracks, :id
  
      def initialize (title, artist, genre, year, tracks, id)
            @title = title
            @artist = artist
            @genre = genre
            @year = year
            @tracks = tracks
            @id = id
      end
  end
  
  class Track
      attr_accessor :name, :location, :duration
  
      def initialize (name, location, duration)
          @name = name
          @location = location
          @duration = duration
      end
  end
  
  # Reads in and returns a single track from the given file
  def read_track(music_file)
        name = music_file.gets().chomp()
        location = music_file.gets().chomp()
        duration = music_file.gets().chomp()
        track = Track.new(name, location, duration)
        return track
  end
  
  # Returns an array of tracks read from the given file
  def read_tracks(music_file)
      
      count = music_file.gets().to_i()
        tracks = Array.new()
  
        i = 0
        while i < count
            track = read_track(music_file)
            tracks << track
            i += 1
        end 
      return tracks
  end
  
  # Takes an array of tracks and prints them to the terminal
  def print_tracks(tracks)
    i = 0
    while i < tracks.length
        print_track(tracks[i])
        i += 1
    end
  end
  
  # Reads in and returns a single album from the given file, with all its tracks
  def read_album(music_file, id)
  
    # read in all the Album's fields/attributes including all the tracks
      album_artist = music_file.gets().chomp()
      album_title = music_file.gets().chomp()
      album_year = music_file.gets().chomp().to_i()
      album_genre = music_file.gets().chomp().to_i()
      tracks = read_tracks(music_file)  
      album = Album.new(album_title, album_artist, album_genre, album_year, tracks, id)
      return album
  end
  
  def read_albums(music_file)
    albums = Array.new()
    # create playlist album - always first album
    playlist = Album.new("Playlist", "User", 0, nil, Array.new(), 0)
    albums.push(playlist)
    album_count = music_file.gets().chomp().to_i()
    i = 1
    while i < album_count+1
      albums.push(read_album(music_file, i))
      i += 1
    end
    return albums
  end

  # Takes a single album and prints it to the terminal
  def print_album(album)
    if album.title != "Playlist" or album.tracks.length > 0
      printf("Album number %i\n", album.id)
      printf("Title: %s\n", album.title)
      printf("Artist: %s\n", album.artist)
      printf("Genre: %s\n", $genre_names[album.genre])
      puts()
    end
  end
  
  # Takes a single track and prints it to the terminal
  def print_track(track)
    puts(track.name)
    puts(track.location)
  end
  
  def play_track(album, track_id)
    printf("Playing track %s from album %s", album.tracks[track_id].name, album.title)
    sleep(3)
  end

  def display_all_albums(albums)
    puts("Display all albums")
    index = 0
      while index < albums.length
        print_album(albums[index])
        index += 1
      end
  end
  # genre should be a string
  def display_albums_by_genre(albums)
    puts("Genre options:")
    i = 1
    while i < $genre_names.length
      printf("%i. %s\n", i, $genre_names[i])
      i += 1
    end
    genre_id = read_integer_in_range("Please enter value", 1, 4)
    i = 0
    count = 0
    while i < albums.length
      if albums[i].genre == genre_id
        print_album(albums[i])
        count += 1
      end
      i += 1
    end
    if count == 0
      printf("No albums of genre '%s'\n", $genre_names[genre_id])
    end
  end

  def album_options(albums)
        i = 0
    while i < albums.length
      printf("%i. %s - %s\n", i, albums[i].artist, albums[i].title)
      i += 1
    end
  end

  def track_options(tracks)
    i = 0
      while i < tracks.length
        printf("%i. %s\n", i, tracks[i].name)
        i += 1
      end
  end

  def select_album_to_play(albums)
    album_options(albums)
    album_id = read_integer_in_range("Enter album number", 0, albums.length-1)
    if albums[album_id].tracks.length == 0
      puts("Album is empty")
    else
      track_options(albums[album_id])
      track_id = read_integer_in_range("Select track to play", 0, albums[album_id].tracks.length-1)
      play_track(albums[album_id], track_id)
    end
    puts("\n")
  end

  def read_in_albums()
    puts("Read in albums")
    begin
      repeat = false
      location = read_string("Please enter location of albums")
      if !File.file?(location)
        repeat = true
        puts("ERROR: File does not exist")
      end
    end while repeat
    music_file = File.new(location, "r")
    albums = read_albums(music_file)
    return albums
  end

  def display_albums(albums)
    begin
      puts ("Display Album menu:")
      puts ("1. Display all albums")
      puts ("2. Display albums by genre")
      puts ("5. Go back")
      begin
        repeat = false
        response = read_integer("Enter a value: ")
        case response
        when 1
          display_all_albums(albums)
        when 2
          display_albums_by_genre(albums)
        when 5
          repeat = false
        else
          puts("Incorrect value. Please try again")
          repeat = true
        end
      end while repeat
    end
  end

  def add_to_playlist(albums)
    puts("Add track to Playlist")
    tracks = Array.new()
    n = 0
    i = 0
    while i < albums.length
      if albums[i].title != "Playlist"
        j = 0
        while j < albums[i].tracks.length
          printf("%i. %s\n", n+1, albums[i].tracks[j].name)
          tracks.push(albums[i].tracks[j])
          j += 1
          n += 1
        end
      end
      i += 1
    end
    track_id = read_integer_in_range("Select track to add to Playlist:", 1, tracks.length)-1
    albums[0].tracks.push(tracks[track_id])
    printf("You added %s to Playlist\n", tracks[track_id].name)
  end

  def menu()
    albums = Array.new()
    albums = read_albums(File.new("albums.txt", 'r')) # remove when submitting
    begin
      puts ("Main Menu:")
      puts ("1. Read in Albums")
      puts ("2. Display Albums")
      puts ("3. Select an Album to play")
      puts ("4. Add to playlist")
      puts ("5. Exit the application")
      exit = false
      begin
        repeat = false
        response = read_integer("Enter a value: ")
        case response
        when 1
          albums = read_in_albums()
        when 2
          display_albums(albums)
        when 3
          select_album_to_play(albums)
        when 4
          add_to_playlist(albums)
        when 5
          exit(0)
        else
          puts("Incorrect value. Please try again")
          repeat = true
        end
      end while repeat
    end while !exit
  end


  # Reads in an album from a file and then print the album to the terminal
  def main()
    menu()
  end
  
  if __FILE__ == $0
    main()
  end
