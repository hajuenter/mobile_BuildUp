import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselSliderWidget extends StatefulWidget {
  const CarouselSliderWidget({super.key});

  @override
  CarouselSliderWidgetState createState() => CarouselSliderWidgetState();
}

class CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  final List<String> images = [
    'assets/logobanner1.png',
    'assets/logobanner2.png',
    'assets/logo.png',
  ];

  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController(); // Menggunakan CarouselSliderController

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return CarouselSlider.builder(
              carouselController:
                  _carouselController, // Menggunakan controller baru
              itemCount: images.length,
              options: CarouselOptions(
                height: constraints.maxWidth * 0.5,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: constraints.maxWidth,
                    color: Colors.grey[200],
                    child: images[index].endsWith('.svg')
                        ? SvgPicture.asset(
                            images[index],
                            width: constraints.maxWidth,
                            fit: BoxFit.cover,
                            placeholderBuilder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          )
                        : Image.asset(
                            images[index],
                            width: constraints.maxWidth,
                            fit: BoxFit.cover,
                          ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: currentIndex,
            count: images.length,
            effect: const ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.blue,
              dotColor: Colors.grey,
            ),
            onDotClicked: (index) {
              _carouselController.jumpToPage(index); // Menggunakan jumpToPage()
            },
          ),
        ),
      ],
    );
  }
}
