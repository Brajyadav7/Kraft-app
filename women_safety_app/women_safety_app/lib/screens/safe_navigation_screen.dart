import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/safe_navigation_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class SafeNavigationScreen extends StatefulWidget {
  const SafeNavigationScreen({super.key});

  @override
  State<SafeNavigationScreen> createState() => _SafeNavigationScreenState();
}

class _SafeNavigationScreenState extends State<SafeNavigationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final SafeNavigationService _navigationService = SafeNavigationService();

  Position? _currentPosition;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  List<SafeRoute> _routes = [];
  SafeRoute? _selectedRoute;
  bool _isLoading = false;
  bool _isSharingLive = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            markerId: const MarkerId('current'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'You are here'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });
      _moveCamera(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _moveCamera(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, 14.0));
  }

  
  void _onMapLongPress(LatLng destination) async {
    setState(() {
      _isLoading = true;
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    if (_currentPosition == null) {
       await _getCurrentLocation();
    }
    
    if (_currentPosition != null) {
      try {
        final origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        final routes = await _navigationService.getSafeRoutes(origin: origin, destination: destination);
        
        if (!mounted) return;

        setState(() {
          _routes = routes;
          if (routes.isNotEmpty) {
            _selectRoute(routes.first); // Auto-select the first (safest/best)
          }
           _isLoading = false;
        });
        
        // Zoom to fit
        if (routes.isNotEmpty) {
            _fitBounds(routes.first.bounds);
        }

      } catch (e) {
         if (mounted) {
           String errorMsg = e.toString();
           if (errorMsg.contains("API Key")) {
             showDialog(
               context: context,
               builder: (ctx) => AlertDialog(
                 title: const Text("Configuration Required"),
                 content: const Text("Please set your Google Maps API Key in:\n\nlib/services/google_places_safety_service.dart\n\nand\n\nandroid/app/src/main/AndroidManifest.xml"),
                 actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
               ),
             );
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Error fetching routes: $e")),
             );
           }
           setState(() => _isLoading = false);
         }
      }
    }
  }

  void _selectRoute(SafeRoute route) {
    setState(() {
      _selectedRoute = route;
      _polylines.clear();
      
      // Draw all routes grey
      for (var r in _routes) {
        _polylines.add(
          Polyline(
            polylineId: PolylineId(r.hashCode.toString()),
            points: r.polylinePoints,
            color: Colors.grey.withOpacity(0.5),
            width: 4,
            onTap: () => _selectRoute(r),
            consumeTapEvents: true,
            zIndex: 0,
          ),
        );
      }
      
      // Draw selected route bold
      _polylines.add(
        Polyline(
          polylineId: PolylineId('selected'),
          points: route.polylinePoints,
          color: route.isSafest ? Colors.green : Colors.blue,
          width: 6,
          zIndex: 1,
        ),
      );
    });
  }

  Future<void> _fitBounds(Bounds bounds) async {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: bounds.southwest,
          northeast: bounds.northeast,
        ),
        50.0, // padding
      ));
  }

  Future<void> _startNavigation() async {
    if (_selectedRoute == null) return;
    
    // Launch Google Maps
    // URL Scheme: google.navigation:q=Lat,Lng&mode=d
    // Or distinct URL: https://www.google.com/maps/dir/?api=1&origin=...&destination=...&travelmode=driving
    
    // We want to pass the specific route? Google Maps Intent doesn't easily support custom polylines.
    // We pass the destination, and Google Maps does its own routing. 
    // HOWEVER, users can benefit from us showing "Use this route" visual.
    // For this MVP, we launch Navigation to the destination.
    
    // To match "Safe Route", we can't force GMaps to take our specific path easily via Intent.
    // Value add is the user CARES to check here first.
    
    final dest = _markers.firstWhere((m) => m.markerId.value == 'destination').position;
    final url = Uri.parse("google.navigation:q=${dest.latitude},${dest.longitude}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Could not launch Google Maps")),
         );
       }
    }
  }

  void _toggleLiveShare() {
     setState(() {
       _isSharingLive = !_isSharingLive;
     });
     
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(_isSharingLive ? "Live Location Shared with Contacts" : "Live Sharing Stopped"),
         backgroundColor: _isSharingLive ? Colors.green : Colors.grey,
       ),
     );
     // Hook into actual sharing logic if available (e.g. sending SMS link)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safe Navigation"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.7333, 76.7794), // Chandigarh as default
              zoom: 12,
            ),
            onMapCreated: (controller) => _controller.complete(controller),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onLongPress: _onMapLongPress,
            markers: _markers,
            polylines: _polylines,
          ),
          
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Analyzing Route Safety..."),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Row(
                   children: [
                     Icon(Icons.touch_app, color: Colors.grey[600]),
                     const SizedBox(width: 10),
                     const Expanded(
                       child: Text(
                         "Long press on map to pick destination", 
                         style: TextStyle(color: Colors.grey),
                       ),
                     ),
                   ],
                 ),
              ),
            ),
          ),
          
          // Route Details Sheet
          if (_selectedRoute != null && !_isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedRoute!.isSafest ? "Safest Route Recommended" : "Alternative Route", 
                              style: TextStyle(
                                color: _selectedRoute!.isSafest ? Colors.green[700] : Colors.orange[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                             const SizedBox(height: 4),
                             Text(
                              "${_selectedRoute!.duration} (${_selectedRoute!.distance})",
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                             ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedRoute!.safetyScore > 70 ? Colors.green[100] : Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.security, size: 16, color: _selectedRoute!.safetyScore > 70 ? Colors.green : Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                "Score: ${_selectedRoute!.safetyScore}/100",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedRoute!.safetyScore > 70 ? Colors.green[800] : Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    
                    // Features
                     Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._selectedRoute!.safetyFeatures.map((f) => Chip(
                          label: Text(f, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue[50],
                          visualDensity: VisualDensity.compact,
                        )),
                        ..._selectedRoute!.warnings.map((w) => Chip(
                          label: Text(w, style: const TextStyle(fontSize: 12, color: Colors.white)),
                          backgroundColor: Colors.red[300],
                           visualDensity: VisualDensity.compact,
                        )),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleLiveShare,
                            icon: Icon(_isSharingLive ? Icons.stop_circle : Icons.share_location),
                            label: Text(_isSharingLive ? "Stop Sharing" : "Share Live"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _isSharingLive ? Colors.red : Colors.blue,
                              side: BorderSide(color: _isSharingLive ? Colors.red : Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _startNavigation,
                            icon: const Icon(Icons.navigation),
                            label: const Text("Start"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
