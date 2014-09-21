#############################################################
# DreamNetwork streaming infrastructure
#
# Transcoding method extension from v2.0 which delivers a
# metadata-less OGG stream and therefore circumvents a bug
# in modern browsers where the stream breaks on metadata
# change.
#############################################################

%include "lib_dn.liq"

def encode(channel, password, ~stream_name="Livestream", ~stream_description="powered by DreamNetwork", ~stream_url="http://dreamnetwork.kthx.at/", ~stream_genre="Various", ~stream_public=true)

	master = drop_metadata(mksafe(merge_tracks(dreamnetwork_master_input(channel))))

	publish = dreamnetwork_publish(stream_name=stream_name, stream_description=stream_description, stream_url=stream_url, stream_public=stream_public, stream_genre=stream_genre, channel, password)

	publish("vorbis_hq_wk.ogg", "vorbis", 96, master)
end
