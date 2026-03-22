import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const SmartSaveApp());
}

class SmartSaveApp extends StatelessWidget {
  const SmartSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  void _loadAds() {
    if (_isPremium) return;
    
    // 1. Banner Ad (Bottom)
    BannerAd(
      adUnitId: 'ca-app-pub-1233913749835554/4725006463',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _bannerAd = ad as BannerAd),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    ).load();

    // 2. Interstitial Ad (Full Screen)
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1233913749835554/9071445588',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );

    // 3. Rewarded Ad (Premium Unlock)
    RewardedAd.load(
      adUnitId: 'ca-app-pub-1233913749835554/4334124229',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void _showInterstitial() {
    if (_interstitialAd != null && !_isPremium) {
      _interstitialAd!.show();
      _loadAds(); // Reload for next time
    }
  }

  void _showRewarded() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        setState(() { _isPremium = true; });
        _bannerAd?.dispose();
        _bannerAd = null;
      });
      _loadAds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ad loading... Please try again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SmartSave AI 🚀")