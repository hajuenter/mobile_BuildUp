import 'package:flutter/material.dart';
import '../responses/data_cpb_response.dart';
import '../models/data_cpb_model.dart';
import '../services/api_service.dart';
import 'data_cpb_detail.dart';
import 'verifikasi_screen.dart';

class DataAndVerifikasiScreen extends StatefulWidget {
  const DataAndVerifikasiScreen({super.key});

  @override
  DataAndVerifikasiScreenState createState() => DataAndVerifikasiScreenState();
}

class DataAndVerifikasiScreenState extends State<DataAndVerifikasiScreen> {
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        selectedTabIndex = (args is int) ? args : 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: selectedTabIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF0D6EFD),
          title: Text(
            'Data CPB dan Verifikasi',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white), // Tombol kembali putih
            onPressed: () =>
                Navigator.pop(context), // Kembali ke halaman sebelumnya
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'DAFTAR'),
              Tab(text: 'DAFTAR VERIFIKASI'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DataCpbList(),
            VerifikasiCpbList(),
          ],
        ),
      ),
    );
  }
}

class DataCpbList extends StatefulWidget {
  const DataCpbList({super.key});

  @override
  DataCpbListState createState() => DataCpbListState();
}

class DataCpbListState extends State<DataCpbList> {
  late Future<DataCPBResponse> futureDataCPB;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      futureDataCPB = ApiService().getDataCPB();
    });
  }

  void _hapusData(int id) async {
    bool confirm = await _tampilkanKonfirmasiHapus();
    if (confirm) {
      DataCPBResponse response = await ApiService().deleteDataCPB(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );

      if (response.status) {
        fetchData();
      }
    }
  }

  Future<bool> _tampilkanKonfirmasiHapus() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Konfirmasi"),
            content: Text("Apakah Anda yakin ingin menghapus data ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(3),
        child: RefreshIndicator(
          onRefresh: () async {
            fetchData();
            await Future.delayed(Duration(seconds: 1));
          },
          child: FutureBuilder<DataCPBResponse>(
            future: futureDataCPB,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Gagal memuat data"));
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return CustomScrollView(
                  // ✅ Agar bisa di-scroll meski data kosong
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("Data kosong")),
                    ),
                  ],
                );
              }

              List<DataCPBModel> dataCpb = snapshot.data!.data
                  .where((item) => item.pengecekan == "Belum Dicek")
                  .toList();

              if (dataCpb.isEmpty) {
                return CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                          child: Text("Tidak ada data yang belum dicek.")),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: dataCpb.length,
                itemBuilder: (context, index) {
                  final item = dataCpb[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifikasiScreen(data: item),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: EdgeInsets.all(
                            10), // Padding untuk tampilan lebih rapi
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFF0D6EFD),
                              child: Text(
                                item.id.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10), // Spasi antara avatar dan teks
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nama,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('NIK: ${item.nik}'),
                                  Text('Alamat: ${item.alamat}'),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.visibility,
                                      color: Colors.blue), // Detail
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DataCpbDetail(data: item),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 2), // Spasi antara tombol
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red), // Hapus
                                  onPressed: () => _hapusData(item.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class VerifikasiCpbList extends StatefulWidget {
  const VerifikasiCpbList({super.key});

  @override
  VerifikasiCpbListState createState() => VerifikasiCpbListState();
}

class VerifikasiCpbListState extends State<VerifikasiCpbList> {
  late Future<DataCPBResponse> futureVerifikasiCpb;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      futureVerifikasiCpb = ApiService().getDataCPB();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(3),
        child: RefreshIndicator(
          onRefresh: () async {
            fetchData();
            await Future.delayed(Duration(seconds: 1)); // Simulasi delay
          },
          child: FutureBuilder<DataCPBResponse>(
            future: futureVerifikasiCpb,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Gagal memuat data"));
              } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                return CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text("Data kosong")),
                    ),
                  ],
                );
              }

              // 🔹 Filter data dengan pengecekan "Sudah Dicek"
              List<DataCPBModel> verifikasiCpb = snapshot.data!.data
                  .where((item) => item.pengecekan == "Sudah Dicek")
                  .toList();

              if (verifikasiCpb.isEmpty) {
                return CustomScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                          child: Text("Tidak ada data yang sudah dicek.")),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: verifikasiCpb.length,
                itemBuilder: (context, index) {
                  final item = verifikasiCpb[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🔹 Avatar berdasarkan status
                          CircleAvatar(
                            backgroundColor: item.status == "Terverifikasi"
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              item.status == "Terverifikasi"
                                  ? Icons.check
                                  : Icons.close,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nama,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('NIK: ${item.nik}'),
                                Text('Alamat: ${item.alamat}'),
                                Text(
                                  'Status: ${item.status}',
                                  style: TextStyle(
                                    color: item.status == "Terverifikasi"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
