import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad service for managing rewarded ads
/// 
/// Handles ad loading, showing, and reward callbacks.
class AdService {
  RewardedAd? _rewardedAd;
  bool _initialized = false;
  
  // Test ad unit IDs - replace with real ones in production
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _initialized = true;
    await _loadRewardedAd();
  }
  
  Future<void> _loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }
  
  bool get isAdReady => _rewardedAd != null;
  
  Future<bool> showRewardedAd({
    required Function onRewarded,
    Function? onFailed,
  }) async {
    if (_rewardedAd == null) {
      onFailed?.call();
      return false;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        onFailed?.call();
      },
    );
    
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
    
    return true;
  }
}
