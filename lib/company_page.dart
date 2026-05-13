import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'PT SMART Tbk',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.green[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _TentangKamiSection(),
            _NilaiNilaiSection(),
            _KegiatanBisnisSection(),
            _ProdukLayananSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Container(
      width: double.infinity,
      height: isMobile ? 400 : 600,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hero.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24.0 : 64.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mewujudkan Masa Depan Berkelanjutan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 32 : 56,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Perusahaan agribisnis kelapa sawit terintegrasi dan terkemuka di Indonesia, berkomitmen pada kualitas dan keberlanjutan.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isMobile ? 16 : 22,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Pelajari Lebih Lanjut',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TentangKamiSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 120.0 : 24.0,
        vertical: 80.0,
      ),
      color: Colors.grey[50],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'TENTANG KAMI',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PT Sinar Mas Agro Resources and Technology Tbk',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PT SMART Tbk adalah salah satu perusahaan publik produk konsumen berbasis kelapa sawit yang terintegrasi dan terkemuka di Indonesia. Kami beroperasi mengelola perkebunan kelapa sawit di Indonesia dan menghasilkan produk-produk turunan berkualitas tinggi, dari bibit hingga menjadi produk di rak (seed-to-shelf). Kami bangga berkontribusi dalam memenuhi permintaan global yang terus meningkat akan produk kelapa sawit berkelanjutan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NilaiNilaiSection extends StatelessWidget {
  final List<Map<String, String>> nilaiNilai = [
    {
      'title': 'Integritas (Integrity)',
      'desc': 'Mewujudkan pernyataan atau janji ke dalam tindakan untuk memperoleh kepercayaan.',
      'icon': 'verified_user'
    },
    {
      'title': 'Sikap Positif (Positive Attitude)',
      'desc': 'Perilaku yang mendukung terciptanya lingkungan kerja yang saling menghargai dan kondusif.',
      'icon': 'mood'
    },
    {
      'title': 'Komitmen (Commitment)',
      'desc': 'Melaksanakan pekerjaan dengan sepenuh hati untuk mencapai hasil terbaik.',
      'icon': 'handshake'
    },
    {
      'title': 'Perbaikan Berkelanjutan',
      'desc': 'Terus meningkatkan kemampuan diri, unit kerja, dan organisasi.',
      'icon': 'trending_up'
    },
    {
      'title': 'Inovasi (Innovation)',
      'desc': 'Menciptakan ide-ide baru yang meningkatkan produktivitas dan pertumbuhan.',
      'icon': 'lightbulb'
    },
    {
      'title': 'Loyalitas (Loyalty)',
      'desc': 'Menanamkan semangat memahami dan melaksanakan nilai-nilai inti perusahaan.',
      'icon': 'favorite'
    },
  ];

  IconData _getIconData(String name) {
    switch (name) {
      case 'verified_user': return Icons.verified_user_outlined;
      case 'mood': return Icons.mood_outlined;
      case 'handshake': return Icons.handshake_outlined;
      case 'trending_up': return Icons.trending_up_outlined;
      case 'lightbulb': return Icons.lightbulb_outline;
      case 'favorite': return Icons.favorite_border;
      default: return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 120.0 : 24.0,
        vertical: 80.0,
      ),
      child: Column(
        children: [
          Text(
            'NILAI-NILAI PERUSAHAAN',
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nilai Inti (Shared Values)',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nilai-nilai yang menjadi dasar setiap keputusan bisnis kami setiap harinya.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.maxWidth > 900) crossAxisCount = 3;
              else if (constraints.maxWidth > 600) crossAxisCount = 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: isDesktop ? 1.4 : 1.2,
                ),
                itemCount: nilaiNilai.length,
                itemBuilder: (context, index) {
                  final item = nilaiNilai[index];
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(item['icon']!),
                            color: Colors.green[700],
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            item['desc']!,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KegiatanBisnisSection extends StatelessWidget {
  final List<Map<String, String>> kegiatan = [
    {
      'title': 'Hulu (Upstream)',
      'desc': 'Penanaman, pemeliharaan, dan pemanenan pohon kelapa sawit di perkebunan kami.',
      'image': 'nature'
    },
    {
      'title': 'Pengolahan (Milling)',
      'desc': 'Mengolah Tandan Buah Segar (TBS) menjadi Crude Palm Oil (CPO) dan inti sawit (PK).',
      'image': 'factory'
    },
    {
      'title': 'Hilirisasi (Downstream)',
      'desc': 'Pemrosesan CPO menjadi produk konsumen seperti minyak goreng, margarin, dan oleokimia.',
      'image': 'science'
    },
    {
      'title': 'Perdagangan (Trading)',
      'desc': 'Pemasaran dan distribusi produk berbasis kelapa sawit ke pasar domestik dan internasional.',
      'image': 'public'
    },
  ];

  IconData _getIconData(String name) {
    switch (name) {
      case 'nature': return Icons.nature_people_outlined;
      case 'factory': return Icons.precision_manufacturing_outlined;
      case 'science': return Icons.science_outlined;
      case 'public': return Icons.public_outlined;
      default: return Icons.eco_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 120.0 : 24.0,
        vertical: 80.0,
      ),
      color: Colors.green[900],
      child: Column(
        children: [
          Text(
            'KEGIATAN BISNIS',
            style: TextStyle(
              color: Colors.green[300],
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dari Bibit Hingga Produk (Seed-to-Shelf)',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              if (constraints.maxWidth > 900) crossAxisCount = 4;
              else if (constraints.maxWidth > 600) crossAxisCount = 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: isDesktop ? 0.8 : 1.2,
                ),
                itemCount: kegiatan.length,
                itemBuilder: (context, index) {
                  final item = kegiatan[index];
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getIconData(item['image']!),
                          color: Colors.green[300],
                          size: 40,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Text(
                            item['desc']!,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProdukLayananSection extends StatelessWidget {
  final List<Map<String, dynamic>> produk = [
    {
      'title': 'Produk Konsumen Berbasis Sawit',
      'desc': 'Minyak goreng, margarin, dan shortening berkualitas seperti Filma, Kunci Mas, dan Mitra.',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'title': 'Oleokimia',
      'desc': 'Turunan kelapa sawit untuk industri perawatan pribadi, kosmetik, farmasi, hingga plastik.',
      'icon': Icons.water_drop_outlined,
    },
    {
      'title': 'Bioenergi',
      'desc': 'Produksi biodiesel yang mendukung kebijakan energi terbarukan ramah lingkungan.',
      'icon': Icons.bolt_outlined,
    },
    {
      'title': 'Inovasi Pangan & Nutrisi',
      'desc': 'Pengembangan produk baru dan formulasi yang berfokus pada kualitas nutrisi optimal.',
      'icon': Icons.restaurant_menu_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 120.0 : 24.0,
        vertical: 80.0,
      ),
      child: Column(
        children: [
          Text(
            'PRODUK & LAYANAN',
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Kualitas Tinggi untuk Kebutuhan Global',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: produk.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final item = produk[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.green[700],
                    size: 28,
                  ),
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    item['desc'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: Colors.grey[900],
      child: Column(
        children: [
          Text(
            'PT Sinar Mas Agro Resources and Technology Tbk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Sinar Mas Land Plaza, Tower II, 30th Floor\nJl. M.H. Thamrin No. 51, Jakarta 10350, Indonesia',
            style: TextStyle(color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            '© 2026 PT SMART Tbk. All Rights Reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
