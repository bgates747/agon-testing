from pytube import YouTube
import os
from moviepy.editor import AudioFileClip
from pydub import AudioSegment, effects

def get_youtube_audio(url):
    yt = YouTube(url)
    audio_stream = yt.streams.filter(only_audio=True).first()
    filename = audio_stream.default_filename
    return filename, audio_stream


if __name__ == "__main__":
    current_url = "https://www.youtube.com/watch?v=6VCBAHufFHM"
    saved_songs_dir = "organ/src/samples"

    song_filename, audio_stream = get_youtube_audio(current_url)
    input_file = os.path.join(saved_songs_dir, song_filename)
    # base_filename = os.path.splitext(input_file)[0]
    # output_file = f"{base_filename}.wav"


    audio_stream.download(saved_songs_dir)
    print(f"Downloaded {song_filename} to {saved_songs_dir}")

    # print(output_file)

    # audio = AudioSegment.from_file(input_file)
    # audio.export(output_file, format="wav")
