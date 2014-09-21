#############################################################
# DreamNetwork streaming infrastructure
#
# Transcoding method variation from v2.0 with focus on
# delivering the highest possible quality and compatibility.
#
# Used for /r/ASOT for example.
#############################################################

%include "lib_dn.liq"

def encode(channel, password, ~stream_name="Livestream", ~stream_description="powered by DreamNetwork", ~stream_url="http://dreamnetwork.kthx.at/", ~stream_genre="Various", ~stream_public=true)

	master = dreamnetwork_master_input(channel)

	publish = dreamnetwork_publish(stream_name=stream_name, stream_description=stream_description, stream_url=stream_url, stream_public=stream_public, stream_genre=stream_genre, channel, password)

	publish("aacp_lq.aac", "he_aac_v2", 32, master)
	publish("aacp_hq.aac", "he_aac", 64, master)
	publish("vorbis_hq.ogg", "vorbis", 128, master)
	publish("mpeg3_hq.mp3", "mp3", 320, master)
end
