import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/home_screen.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PartCataloguePage extends StatefulWidget {
  @override
  _PartCataloguePageState createState() => _PartCataloguePageState();
}

class _PartCataloguePageState extends State<PartCataloguePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  Stream<List<PartCatalogueItem>> getPartCatalogueItems() {
    if (_searchText.isEmpty) {
      return FirebaseFirestore.instance
          .collection('PartCatalogue')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PartCatalogueItem.fromDocument(doc))
              .toList());
    } else {
      return FirebaseFirestore.instance
          .collection('PartCatalogue')
          .where('JenisMobil', isGreaterThanOrEqualTo: _searchText)
          .where('JenisMobil', isLessThanOrEqualTo: _searchText + '\uf8ff')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PartCatalogueItem.fromDocument(doc))
              .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 145, 0),
        title: Text("Part Catalogue"),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            
          DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/unitedtractors.png"),
                        fit: BoxFit.cover, // Membuat gambar menutupi seluruh area
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.orange.withOpacity(0.6),
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "PT. UNITEDTRACTORS\nUJUNG PANDANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),



              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
                child: ListTile(
                  trailing: Icon(Icons.search),
                  title: Text("Find Error Code"),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartCataloguePage()));
                },
                child: ListTile(
                  trailing: Icon(Icons.book),
                  title: Text("Part Catalogue"),
                ),
              ),
          ],
        ),
      ),
      
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Jenis Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PartCatalogueItem>>(
              stream: getPartCatalogueItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;
                if (items.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => View(
                            url: item.pdfUrl,
                            jenisMobil: item.jenisMobil,
                          ),
                        ),
                      ),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                item.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(item.jenisMobil),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PartCatalogueItem {
  final String id;
  final String jenisMobil;
  final String imageUrl;
  final String pdfUrl;

  PartCatalogueItem({
    required this.id,
    required this.jenisMobil,
    required this.imageUrl,
    required this.pdfUrl,
  });

  factory PartCatalogueItem.fromDocument(DocumentSnapshot doc) {
    return PartCatalogueItem(
      id: doc.id,
      jenisMobil: doc['JenisMobil'] ?? 'Unknown',
      imageUrl: doc['imageUrl'] ?? '',
      pdfUrl: doc['pdfUrl'] ?? '',
    );
  }
}

class View extends StatelessWidget {
  final String url;
  final String jenisMobil;

  View({required this.url, required this.jenisMobil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(jenisMobil),  // Title set to the name of JenisMobil
        backgroundColor: Colors.orange,
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
