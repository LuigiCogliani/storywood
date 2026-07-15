import 'package:flutter/material.dart';

import '../../screens/cast_screen.dart';
import '../../data/api_constants.dart';
import '../../data/theme_data.dart';

import '../material_wrapped.dart';

/// NOTE: in this widget the sizes are hard coded (instead of
/// being expressed in multiples of the screen size) because the font in the cast
/// card is particulary small and would not work with the scaling of the cards.
/// (the font is hard coded and does not scale with the screen size)
class CastScroll extends StatelessWidget {
  final List<Map> movieCast;
  const CastScroll({required this.movieCast, super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      // horizontal scroll
      scrollDirection: Axis.horizontal,
      itemCount: movieCast.length,
      itemBuilder: (context, index) {
        final castEntity = movieCast[index];
        return CastCard(castEntity: castEntity);
      },
    );
  }
}

class CastCard extends StatelessWidget {
  const CastCard({
    super.key,
    required this.castEntity,
  });

  final Map castEntity;

  @override
  Widget build(BuildContext context) {
    return MaterialWrapped(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(CastScreen.routeName, arguments: castEntity);
        },
        child: SizedBox(
          height: 100,
          width: 150,
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                '${ApiConstants.baseImageUrl}${castEntity['profile_path']}' ??
                                    constDefaultImageMisingPlaceholder),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Text(
                    castEntity['name'],
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: constDisplaySmallDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 2,
                  ),
                  child: Text(
                    castEntity['character'],
                    // fade allows to see at least the top half of the widget, while fading out at the bottom
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: constDisplaySmallDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
