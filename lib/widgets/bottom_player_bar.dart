import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player/utils/audio_player_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class BottomPlayerBar extends StatefulWidget {
  const BottomPlayerBar({Key? key}) : super(key: key);

  @override
  _BottomPlayerBarState createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends State<BottomPlayerBar> {
  late AudioPlayerManager _playerManager;

  @override
  void initState() {
    super.initState();
    _playerManager = AudioPlayerManager.getInstance()!;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('hello');
      },
      child: Consumer2<PlayerState, SequenceState?>(
        builder: (BuildContext context,
            PlayerState playerState,
            SequenceState? sequenceState,
            Widget? child,) {
          final sequence = sequenceState?.sequence;
          final metadata = sequenceState?.currentSource?.tag;
          final processingState = playerState.processingState;
          final playing = playerState.playing;

          return Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              Container(
                  height: 70,
                  width: 70,
                  child: CachedNetworkImage(
                      imageUrl:
                      sequence?.isEmpty ?? true
                          ? 'https://cdn2.jianshu.io/assets/default_avatar/4-3397163ecdb3855a0a4139c34a695885.jpg'
                          :metadata.song.album.picUrl)),
              Positioned(
                left: 90,
                child: SizedBox(
                    width: 240,
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sequence?.isEmpty ?? true?'Tap to Enter':metadata.song.name,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          sequence?.isEmpty ?? true?'artist':metadata.song.showArtist(),
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )),
              ),
              Positioned(
                right: 10,
                child: Row(
                  children: [
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering)
                      const CircularProgressIndicator()
                    else
                      if (playing != true)
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: _playerManager.audioPlayer.play,
                        )
                      else
                        if (processingState != ProcessingState.completed)
                          IconButton(
                            icon: const Icon(Icons.pause),
                            onPressed: _playerManager.audioPlayer.pause,
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.replay),
                            onPressed: () =>
                                _playerManager.audioPlayer.seek(Duration.zero),
                          ),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.view_list)),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}