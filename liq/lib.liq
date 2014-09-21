#############################################################
# DreamNetwork generic library for channels
#
# Contains a few shared methods
#############################################################

set("log.file", true)
set("log.file.path", "/var/log/liquidsoap/<script>.log")

def transition_crossfade(oldlen, newlen, oldsrc, newsrc)
	source.skip(oldsrc)
	add(normalize=false, [
		fade.initial(duration=oldlen, newsrc),
		fade.final(duration=newlen, sequence(merge=true, [ oldsrc, empty() ]))
	])
end

def transition_generic(presrc, oversrc, oldsrc, newsrc)
	# When we go back to oldsrc later, do not continue playing the old track
	source.skip(oldsrc)

	add(normalize=false, [
		fade.final(duration=2., sequence(merge=true, [ oldsrc, empty() ])),
		sequence([
			blank(duration=1.),
			presrc,
			fade.initial(duration=0.33, newsrc),
			add(normalize=false, [
				newsrc,
				oversrc
			])
		]),
	])
end

def vst(vst_p, stream) =
	# Random number to append to not intervene with existing processor streams
	sid = string_of(random.float())

	# Signal processing, piped through npipe, see https://github.com/icedream/npipe.
	output.external(
		id="output",
		%wav(header=false, channels=2, samplerate=44100),
		"mrswatson -q -p #{vst_p} -i - -o - | npipe server liquidsoap_#{sid}_processed",
		stream
	)

	# Recover metadata from original stream the lazy way
	add(normalize=false, [
		amplify(0., stream),
		input.external(
			id="output_processed_read",
			samplerate=44100,
			"npipe client liquidsoap_#{sid}_processed"
		)
	])
end
