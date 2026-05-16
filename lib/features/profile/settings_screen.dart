import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ride_link/features/profile/profile_navbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.changePasswordPath,
  });

  final String changePasswordPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final supabase = Supabase.instance.client;
    return Center(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const ProfileNavbar(),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text('Manage your account preferences and security'),
      
                const SizedBox(height: 30,),
      
                Text("Security", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),),
                
                const SizedBox(height: 10,),
      
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => context.push(changePasswordPath),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.restore, size: 16, color: colors.primary,),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Change Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              Text("Update your password to keep your account secure", style: TextStyle(fontSize: 12, color: Colors.grey),)
                            ],
                          ),

                          Icon(Icons.arrow_forward_ios, size: 16, color: colors.primary,),

                        ],
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(height: 30,),
      
                Text("App Info", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),),
                
                const SizedBox(height: 10,),
      
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Version", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                      Text("0.2.0-alpha", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                    ],
                  ),
                ),
      
                const SizedBox(height: 30,),
      
                Text("Account", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),),
      
                const SizedBox(height: 10,),
      
                SizedBox(
                  width: 100,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await supabase.auth.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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