#############################################################
# DreamNetwork library
#
# Contains the main library functions for dealing with
# streaming to the DreamNetwork streaming infrastructure.
#############################################################

dreamnetwork_master_host = "publish.internal.stream.kthx.at"
dreamnetwork_master_port = 8080

dreamnetwork_internal_host = "publish.internal.stream.kthx.at"
dreamnetwork_internal_port = 61120

dreamnetwork_input_host = "input.internal.stream.kthx.at"
dreamnetwork_input_port = 61120

dreamnetwork_codecs = [
	("he_aac_v2", [
		(32, %fdkaac(samplerate=32000, bitrate=32, afterburner=true, aot="mpeg2_he_aac_v2")),
		(40, %fdkaac(samplerate=32000, bitrate=40, afterburner=true, aot="mpeg2_he_aac_v2")),
		(48, %fdkaac(samplerate=44100, bitrate=48, afterburner=true, aot="mpeg2_he_aac_v2")),
		(56, %fdkaac(samplerate=44100, bitrate=56, afterburner=true, aot="mpeg2_he_aac_v2")),
		(64, %fdkaac(samplerate=44100, bitrate=64, afterburner=true, aot="mpeg2_he_aac_v2"))
	]),

	("he_aac", [
		(48, %fdkaac(samplerate=44100, bitrate=48, afterburner=true, aot="mpeg2_he_aac")),
		(56, %fdkaac(samplerate=44100, bitrate=56, afterburner=true, aot="mpeg2_he_aac")),
		(64, %fdkaac(samplerate=44100, bitrate=64, afterburner=true, aot="mpeg2_he_aac")),
		(72, %fdkaac(samplerate=44100, bitrate=64, afterburner=true, aot="mpeg2_he_aac")),
		(80, %fdkaac(samplerate=44100, bitrate=64, afterburner=true, aot="mpeg2_he_aac"))
	]),

	("vorbis", [
		(56, %ogg(%vorbis(samplerate=44100, channels=2, quality=-0.07))),
		(64, %ogg(%vorbis(samplerate=44100, channels=2, quality=-0.02))),
		(72, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.03))),
		(80, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.08))),
		(88, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.13))),
		(96, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.18))),
		(112, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.23))),
		(128, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.27))),
		(160, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.34))),
		(192, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.40))),
		(224, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.46))),
		(256, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.52))),
		(320, %ogg(%vorbis(samplerate=44100, channels=2, quality=0.6)))
	]),

	("mp3", [
		(16, %mp3(internal_quality=0, samplerate=22050, bitrate=16)),
		(24, %mp3(internal_quality=0, samplerate=22050, bitrate=24)),
		(32, %mp3(internal_quality=0, samplerate=22050, bitrate=32)),
		(40, %mp3(internal_quality=0, samplerate=22050, bitrate=40)),
		(48, %mp3(internal_quality=0, samplerate=22050, bitrate=48)),
		(56, %mp3(internal_quality=0, samplerate=32000, bitrate=56)),
		(64, %mp3(internal_quality=0, samplerate=32000, bitrate=64)),
		(80, %mp3(internal_quality=0, samplerate=32000, bitrate=80)),
		(96, %mp3(internal_quality=0, samplerate=44100, bitrate=96)),
		(112, %mp3(internal_quality=0, samplerate=44100, bitrate=112)),
		(128, %mp3(internal_quality=0, samplerate=44100, bitrate=128)),
		(144, %mp3(internal_quality=0, samplerate=44100, bitrate=144)),
		(160, %mp3(internal_quality=1, samplerate=44100, bitrate=160)),
		(192, %mp3(internal_quality=1, samplerate=44100, bitrate=192)),
		(224, %mp3(internal_quality=1, samplerate=44100, bitrate=224)),
		(256, %mp3(samplerate=44100, bitrate=256)),
		(320, %mp3(samplerate=44100, bitrate=320))
	]),

	("flac", [
		(0, %ogg(%flac(compression=7, bits_per_sample=16)))
	])
]

def dreamnetwork_publish_metadata(id, stream) =
	# To be rewritten to be sending out metadata via an HTTP API instead

	map_metadata(fun (m) -> begin
		data = json_of(m)
		data = base64.encode(data)

		# export to file asynchronously, the stream would need to hang up for too long to calculate file lengths
		system("/srv/radio/bin/get-metadata -l -c -d" ^ quote(data) ^ " -j" ^ quote("/srv/radio/system/metadata/#{id}.json") ^ " -s" ^ quote(string_of(get(default="", "server.socket.path"))) ^ " >/dev/null&")

		m
	end, stream)
end

def dreamnetwork_publish_master(channel, password, stream,
	~stream_name="Livestream powered by DreamNetwork", ~stream_url="http://dreamnetwork.kthx.at", ~stream_description="powered by DreamNetwork",
	~stream_genre="Various", ~stream_public=true) =
	output.icecast(
		password=password,
		host=dreamnetwork_internal_host,
		port=dreamnetwork_internal_port,
		id="output_icecast_master",
		mount="/#{channel}/master_signal",
		name=stream_name,
		url=stream_url,
		genre=stream_genre,
		description=stream_description,
		public=stream_public,
		icy_metadata="false",
		%ogg(%flac(compression=5)),
		stream)
end

# def dreamnetwork_publish(channel, password, submounts, stream) =
# 	list.iter(fun (i) -> begin
# 		submount = fst(i)
# 		submount_info = snd(i)

# 		codec = fst(submount_info)
# 		bitrate = snd(submount_info)

# 		format = ref %mp3(bitrate=16, samplerate=8000)

# 		list.iter(fun (codec_sub) -> begin
# 			codec_sub_name = fst(codec_sub)
# 			codec_sub_sub = snd(codec_sub)

# 			if codec_sub_name == codec then
# 				list.iter(fun (codec_sub_s) -> begin
# 					codec_sub_bitrate = fst(codec_sub_s)
# 					codec_sub_format = snd(codec_sub_s)

# 					if codec_sub_bitrate == bitrate then
# 						format := codec_sub_format
# 					end

# 					ignore(empty())
# 				end, codec_sub_sub)
# 			end

# 			ignore(empty())
# 		end, dreamnetwork_codecs)

# 		conf_icymeta = if codec == "vorbis" then "false" else "guess" end

# 		ignore(output.icecast(
# 			password=password,
# 			host=dreamnetwork_master_host,
# 			port=dreamnetwork_master_port,
# 			id="output_icecast_#{codec}_#{bitrate}",
# 			mount="/#{channel}/#{submount}",
# 			icy_metadata=conf_icymeta,
# 			!format,
# 			stream))
# 	end, submounts)
# end

def dreamnetwork_publish(channel, password, submount, codec, bitrate, stream, ~stream_name="Livestream powered by DreamNetwork", ~stream_url="http://dreamnetwork.kthx.at", ~stream_description="powered by DreamNetwork",
	~stream_genre="Various", ~stream_public=true) =

	format = ref %mp3(bitrate=16, samplerate=8000)

	list.iter(fun (codec_sub) -> begin
		codec_sub_name = fst(codec_sub)
		codec_sub_sub = snd(codec_sub)

		if codec_sub_name == codec then
			list.iter(fun (codec_sub_s) -> begin
				codec_sub_bitrate = fst(codec_sub_s)
				codec_sub_format = snd(codec_sub_s)

				if codec_sub_bitrate == bitrate then
					format := codec_sub_format
				end

				ignore(empty())
			end, codec_sub_sub)
		end

		ignore(empty())
	end, dreamnetwork_codecs)

	conf_icymeta = if codec == "vorbis" then "false" else "guess" end

	output.icecast(
		password=password,
		host=dreamnetwork_master_host,
		port=dreamnetwork_master_port,
		name=stream_name,
		url=stream_url,
		description=stream_description,
		genre=stream_genre,
		public=stream_public,
		id="output_icecast_#{codec}_#{bitrate}",
		mount="/#{channel}/#{submount}",
		icy_metadata=conf_icymeta,
		!format,
		stream)

end

def dreamnetwork_live_input(channel, liveid, record) =
	s = input.http(
		id="in_live_#{channel}_#{liveid}",
		user_agent="DreamNetwork/0.1.2 (Liquidsoap)",
		timeout=100., # I hate unstable network connections causing fallbacks
		poll_delay=3.,
		max=30.,
		buffer=10.,
		"http://#{dreamnetwork_input_host}:#{dreamnetwork_input_port}/#{channel}/live/#{liveid}"
	)
	s = audio_to_stereo(s)
	#s = skip_blank(s)
	s = rewrite_metadata([("source","in_live"),("liveid",liveid),("channel",channel)], s)
	s = if record then
		output.file(
			fallible=true,
			append=false,
			%mp3(bitrate=320),
			"/srv/radio/system/recordings/#{channel}/live#{liveid}_%Y-%m-%d_%H-%M-%S.mp3",
			s)
	else
		s
	end
	#s = fallback(track_sensitive=false, [s, once(blank(duration=4.)), empty()])
	s
end

def dreamnetwork_master_input(channel) =
	s = input.http(
		id="in_master_#{channel}",
		user_agent="DreamNetwork/0.1.2 (Liquidsoap)",
		timeout=10.,
		poll_delay=2.,
		max=15.,
		buffer=5.,
		"http://#{dreamnetwork_internal_host}:#{dreamnetwork_internal_port}/#{channel}/master_signal"
	)
	#s = mksafe(s)
	s = fallback(
		track_sensitive=false,
		[
			s,
			rewrite_metadata([
				("source","offline"),
				("artist", ""),
				("title", "Stream offline")
			], blank())
		])
	s = rewrite_metadata([("source","in_master"),("channel",channel)], s)
	s
end