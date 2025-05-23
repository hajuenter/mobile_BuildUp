import 'package:flutter/material.dart';
import '../responses/data_cpb_response.dart';
import '../models/data_cpb_model.dart';
import '../services/api_service.dart';
import 'data_cpb_detail_screen.dart';
import 'verifikasi_screen.dart';
import '../widgets/custom_confirmation_dialog.dart';

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
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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

// Common search and filter widget to reuse in both tabs
class SearchAndSortWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String sortBy;
  final Function(String) onSortChanged;

  const SearchAndSortWidget({
    super.key,
    required this.searchController,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
              color: Color(0xFF0D6EFD),
              width: 2), // Add blue border at the bottom
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern search field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan NIK atau Nama',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Color(0xFF0D6EFD)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Modern radio buttons for sorting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Urutkan: ",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  _buildSortRadioButton("NO", "NO"),
                  SizedBox(width: 8),
                  _buildSortRadioButton("A-Z", "asc"),
                  SizedBox(width: 8),
                  _buildSortRadioButton("Z-A", "desc"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortRadioButton(String label, String value) {
    bool isSelected = sortBy == value;

    return InkWell(
      onTap: () => onSortChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0D6EFD) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF0D6EFD) : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF0D6EFD).withAlpha(77),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                margin: EdgeInsets.only(right: 6),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: Color(0xFF0D6EFD),
                  ),
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
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
  List<DataCPBModel> dataCpb = [];
  List<DataCPBModel> filteredDataCpb = [];
  TextEditingController searchController = TextEditingController();
  String sortBy = "NO";

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(() {
      filterData();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchData() async {
    setState(() {
      futureDataCPB = ApiService().getDataCPB();
      sortBy = "NO";
    });

    final response = await futureDataCPB;
    if (response.status) {
      setState(() {
        dataCpb = response.data
            .where((item) => item.pengecekan == "Belum Dicek")
            .toList();
        filterData();
      });
    }
  }

  void filterData() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredDataCpb = List.from(dataCpb);
      } else {
        filteredDataCpb = dataCpb.where((item) {
          return item.nama.toLowerCase().contains(query) ||
              item.nik.toLowerCase().contains(query);
        }).toList();
      }

      sortData();
    });
  }

  void sortData() {
    setState(() {
      if (sortBy == "NO") {
        filteredDataCpb
            .sort((a, b) => a.id.compareTo(b.id)); // Urutkan berdasarkan ID
      } else if (sortBy == "asc") {
        filteredDataCpb.sort((a, b) => a.nama.compareTo(b.nama));
      } else {
        filteredDataCpb.sort((a, b) => b.nama.compareTo(a.nama));
      }
    });
  }

  void changeSorting(String sort) {
    setState(() {
      sortBy = sort;
      sortData();
    });
  }

  void _hapusData(int id) async {
    bool confirm = await showCustomConfirmationDialog(
      context: context,
      title: "Konfirmasi Hapus",
      message: "Apakah Anda yakin ingin menghapus data ini?",
      confirmText: "Hapus",
      cancelText: "Batal",
      confirmIcon: Icons.delete,
      cancelIcon: Icons.close,
      confirmColor: Color(0xFFFF001D),
      logoSvgAsset: "assets/logonew.svg",
      logoSize: 40.0,
    );

    if (confirm) {
      DataCPBResponse response = await ApiService().deleteDataCPB(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
        ),
      );

      if (response.status) {
        fetchData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search and sorting widget
          SearchAndSortWidget(
            searchController: searchController,
            sortBy: sortBy,
            onSortChanged: changeSorting,
          ),

          // List of data
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  sortBy = "NO";
                });
                fetchData();
                await Future.delayed(Duration(seconds: 1));
              },
              color: Color(0xFF0D6EFD),
              child: FutureBuilder<DataCPBResponse>(
                future: futureDataCPB,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      dataCpb.isEmpty) {
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0D6EFD)),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Data CPB kosong"));
                  }

                  if (filteredDataCpb.isEmpty) {
                    return CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  searchController.text.isNotEmpty
                                      ? "Tidak ada hasil pencarian"
                                      : "Tidak ada data CPB yang terdaftar.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: filteredDataCpb.length,
                    itemBuilder: (context, index) {
                      final item = filteredDataCpb[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color(0xFF0D6EFD), width: 1.5),
                        ),
                        color: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.grey.withAlpha(77),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VerifikasiScreen(data: item),
                              ),
                            );
                            if (result == true) {
                              fetchData();
                            }
                          },
                          child: Container(
                            height: 110, // Tinggi tetap untuk semua card
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ID dengan ukuran lebih kecil dan sedikit ke kanan
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Container(
                                    width: 28, // Ukuran lebih kecil
                                    height: 28, // Ukuran lebih kecil
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFF0D6EFD),
                                          width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0D6EFD)
                                              .withAlpha(38),
                                          blurRadius: 3,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 1),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.id.toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF0D6EFD),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12, // Font lebih kecil
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Posisi vertikal di tengah
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'NIK: ${item.nik}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Alamat: ${item.alamat}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Icon tombol lebih kecil dan mepet ke kiri
                                Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Agar tidak mengambil ruang lebih
                                  children: [
                                    SizedBox(
                                      width: 32, // Lebih kecil
                                      height: 32, // Lebih kecil
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: Colors.blue,
                                          size: 25, // Ukuran ikon lebih kecil
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DataCpbDetailScreen(
                                                      data: item),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            5), // Spasi antara tombol dikurangi
                                    SizedBox(
                                      width: 32, // Lebih kecil
                                      height: 32, // Lebih kecil
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 25, // Ukuran ikon lebih kecil
                                        ),
                                        onPressed: () => _hapusData(item.id),
                                      ),
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
        ],
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
  List<DataCPBModel> verifikasiCpb = [];
  List<DataCPBModel> filteredVerifikasiCpb = [];
  TextEditingController searchController = TextEditingController();
  String sortBy = "NO";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filterData();
    });
    fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchData() async {
    setState(() {
      futureVerifikasiCpb = ApiService().getDataCPB();
      sortBy = "NO";
    });

    final response = await futureVerifikasiCpb;
    if (response.status) {
      setState(() {
        verifikasiCpb = response.data
            .where((item) => item.pengecekan == "Sudah Dicek")
            .toList();
        filterData();
      });
    }
  }

  void filterData() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredVerifikasiCpb = List.from(verifikasiCpb);
      } else {
        filteredVerifikasiCpb = verifikasiCpb.where((item) {
          return item.nama.toLowerCase().contains(query) ||
              item.nik.toLowerCase().contains(query);
        }).toList();
      }

      sortData();
    });
  }

  void sortData() {
    setState(() {
      if (sortBy == "NO") {
        filteredVerifikasiCpb
            .sort((a, b) => a.id.compareTo(b.id)); // Urutkan berdasarkan ID
      } else if (sortBy == "asc") {
        filteredVerifikasiCpb.sort((a, b) => a.nama.compareTo(b.nama));
      } else {
        filteredVerifikasiCpb.sort((a, b) => b.nama.compareTo(a.nama));
      }
    });
  }

  void changeSorting(String sort) {
    setState(() {
      sortBy = sort;
      sortData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search and sorting widget
          SearchAndSortWidget(
            searchController: searchController,
            sortBy: sortBy,
            onSortChanged: changeSorting,
          ),

          // List of data
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  sortBy = "NO";
                });
                fetchData();
                await Future.delayed(Duration(seconds: 1));
              },
              color: Color(0xFF0D6EFD),
              child: FutureBuilder<DataCPBResponse>(
                future: futureVerifikasiCpb,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      verifikasiCpb.isEmpty) {
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0D6EFD)),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Data verifikasi kosong"));
                  }

                  if (filteredVerifikasiCpb.isEmpty) {
                    return CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fact_check_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  searchController.text.isNotEmpty
                                      ? "Tidak ada hasil pencarian"
                                      : "Tidak ada data yang sudah di verifikasi.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: filteredVerifikasiCpb.length,
                    itemBuilder: (context, index) {
                      final item = filteredVerifikasiCpb[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
                        ),
                        color: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.grey.withAlpha(77),
                        child: Container(
                          height:
                              125, // Menambahkan tinggi tetap untuk konsistensi
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon status lebih ke kiri
                              Container(
                                width: 36,
                                height: 36,
                                margin: EdgeInsets.only(
                                    left: 0), // Mengatur posisi lebih ke kiri
                                decoration: BoxDecoration(
                                  color: item.status == "Terverifikasi"
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (item.status == "Terverifikasi"
                                          ? Colors.green.withAlpha(51)
                                          : Colors.red.withAlpha(51)),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    item.status == "Terverifikasi"
                                        ? Icons.check
                                        : Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12), // Mengurangi jarak
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize
                                      .min, // Memastikan kolom tidak melebar
                                  children: [
                                    Text(
                                      item.nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1, // Batasi ke 1 baris
                                      overflow: TextOverflow
                                          .ellipsis, // Tambahkan ellipsis jika terlalu panjang
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'NIK: ${item.nik}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Alamat: ${item.alamat}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.status == "Terverifikasi"
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: item.status == "Terverifikasi"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      child: Text(
                                        'Status: ${item.status}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: item.status == "Terverifikasi"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Icon edit dan hapus menggunakan InkWell
                              Container(
                                margin: EdgeInsets.only(right: 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VerifikasiScreen(
                                              data: item,
                                              isEditing: true,
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          fetchData();
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.edit,
                                            color: Colors.blue, size: 25),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            2), // Jarak antar icon diperkecil
                                    InkWell(
                                      onTap: () async {
                                        final konfirmasi =
                                            await showCustomConfirmationDialog(
                                          context: context,
                                          title: "Konfirmasi Hapus",
                                          message:
                                              "Apakah Anda yakin ingin menghapus data verifikasi ini?",
                                          confirmText: "Hapus",
                                          cancelText: "Batal",
                                          confirmIcon: Icons.delete,
                                          cancelIcon: Icons.close,
                                          confirmColor: Color(0xFFFF001D),
                                          logoSvgAsset: "assets/logonew.svg",
                                          logoSize: 40.0,
                                        );

                                        if (!context.mounted) return;

                                        if (konfirmasi) {
                                          try {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Color(0xFF0D6EFD)),
                                                ));
                                              },
                                            );

                                            final response = await ApiService()
                                                .deleteVerifikasiCPBByCpbId(
                                                    item.id);

                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();

                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(response.message),
                                                backgroundColor:
                                                    response.success
                                                        ? Colors.red
                                                        : Colors.red,
                                              ),
                                            );

                                            if (response.success) {
                                              fetchData();
                                            } else {
                                              debugPrint(
                                                  '🔴 Error details: ${response.errors}');
                                            }
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();

                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Terjadi kesalahan tidak terduga: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(Icons.delete,
                                            color: Colors.red, size: 25),
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }
}
