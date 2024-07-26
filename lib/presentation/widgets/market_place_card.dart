import 'package:ecostep/domain/marketplace_item.dart';
import 'package:ecostep/presentation/pages/market_place_detailed_screen.dart';
import 'package:flutter/material.dart';

class MarketplaceCard extends StatefulWidget {
  final MarketplaceItem item;

  MarketplaceCard({
    required this.item,
  });

  @override
  State<MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<MarketplaceCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          // ignore: inference_failure_on_instance_creation
          MaterialPageRoute(
            builder: (context) => MarketplaceDetailScreen(item: widget.item),
          ),
        );
      },
      child: Container(
        child: Card(
          margin: EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: Image.network(
                        widget.item.imageUrl,
                        height: 150.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10.0,
                      right: 10.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 16.0,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16.0,
                            color: Colors.red,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            widget.item.location,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Price: ${widget.item.price}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        'Used for: ${widget.item.usedForMonths} months',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        widget.item.description,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
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
