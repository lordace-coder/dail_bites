import 'dart:convert';

import 'package:dail_bites/bloc/ads/cubit.dart';
import 'package:dail_bites/bloc/cart/cubit.dart';
import 'package:dail_bites/bloc/category_bloc.dart';
import 'package:dail_bites/bloc/pocketbase/pocketbase_service_cubit.dart';
import 'package:dail_bites/bloc/pocketbase/pocketbase_service_state.dart';
import 'package:dail_bites/bloc/products/product_cubit.dart';
import 'package:dail_bites/bloc/wishlist/state.dart';
import 'package:dail_bites/provider/app_provider.dart';
import 'package:dail_bites/ui/pages/home_page.dart';
import 'package:dail_bites/ui/pages/login_page.dart';
import 'package:dail_bites/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart' as toast;

void main() async {
   PWAInstall().setup(installCallback: () {
    debugPrint('APP INSTALLED!');
  });

  final AppDataProvider appData = AppDataProvider();
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final store = AsyncAuthStore(
    save: (String data) async => pref.setString('pb_auth', data),
    initial: pref.getString('pb_auth'),
  );
  final pocketBase = PocketBase(appData.baseUrl, authStore: store);
  final pb = PocketbaseServiceCubit(prefs: pref, pb: pocketBase);
  final wishlistCubit = WishlistCubit(pb: pocketBase);
  try {
    await wishlistCubit.fetchWishlist();
  } catch (e) {}

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PocketbaseServiceCubit>(
          lazy: false,
          create: (context) {
            pb.pb.collection('users').authRefresh();
            return pb;
          },
        ),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(pocketBase: pb.pb),
        ),
        BlocProvider<CategoryCubit>(
          create: (context) => CategoryCubit(pocketBase: pb.pb),
        ),
        BlocProvider<CartCubit>(
          create: (context) => CartCubit(pb: pocketBase),
        ),
        BlocProvider<WishlistCubit>(
          create: (context) => wishlistCubit,
        ),
        BlocProvider<AdsCubit>(
          create: (context) {
            final ad = AdsCubit(
              pb: pb.pb,
            );
            ad.fetchRandomAds();
            return ad;
          },
          lazy: false,
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    // Wait for the widget to be fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PocketbaseServiceCubit>().state;
      final pb = state.pb;

      // Set up auth listener
      pb.authStore.onChange.listen((event) {
        if (!pb.authStore.isValid) {
          AppRouter().navigateAndRemoveUntil(const LoginPage());
        } else {
          // add data to sharedpreferences
          state.updateAuthStore(
              model: json.encode(event.model), token: event.token);
          AppRouter().navigateAndRemoveUntil(const HomePage());
        }
      });

      // Check initial auth state
      if (!pb.authStore.isValid) {
        AppRouter().navigateAndRemoveUntil(const LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return toast.ToastificationWrapper(
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.itimTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.oswald(textStyle: textTheme.bodyMedium),
          ),
        ),
        navigatorKey: AppRouter().navigatorKey,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<PocketbaseServiceCubit, BackendService>(
          builder: (context, pb) {
            // Use a builder to determine initial route
            return pb.pb.authStore.isValid
                ? const HomePage()
                : const LoginPage();
          },
        ),
      ),
    );
  }
}
