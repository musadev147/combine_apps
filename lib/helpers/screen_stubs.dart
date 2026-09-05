import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/common_wigdets/custom_image_view.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

// Helper for beautiful gradients
class PremiumBackground extends StatelessWidget {
  final Widget child;
  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFEDF2F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

// Global Custom Card Widget
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  const PremiumCard({super.key, required this.child, this.padding, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// 1. HOME SCREEN (Tenant)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Farhan Chowdhury",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.allPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.appThemeColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: AppColors.appThemeColor, size: 26.r),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Premium Gradient Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0461D3), Color(0xFF032262)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0461D3).withOpacity(0.3),
                        blurRadius: 12.r,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Monthly Rent Due",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "৳ 28,500.00",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Due Date: June 10, 2026",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Text(
                              "Pay Now",
                              style: TextStyle(
                                color: AppColors.allPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Quick Actions
                Text(
                  "Quick Services",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceItem(Icons.build, "Repair Request", Colors.orange),
                    _buildServiceItem(Icons.receipt_long, "Utility Bills", Colors.green),
                    _buildServiceItem(Icons.verified_user, "Lease Copy", Colors.blue),
                    _buildServiceItem(Icons.support_agent, "Contact Owner", Colors.purple),
                  ],
                ),
                SizedBox(height: 24.h),

                // Recent Activities
                Text(
                  "Recent Updates",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                PremiumCard(
                  child: Column(
                    children: [
                      _buildActivityRow(
                        Icons.payment,
                        "May Rent Paid Successfully",
                        "May 02, 2026 - 10:14 AM",
                        Colors.green,
                      ),
                      const Divider(height: 20),
                      _buildActivityRow(
                        Icons.check_circle_outline,
                        "Plumbing Request Resolved",
                        "April 28, 2026 - 04:30 PM",
                        Colors.blue,
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

  Widget _buildServiceItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          height: 54.h,
          width: 54.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.r),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 75.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(IconData icon, String title, String subtitle, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.r),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 2. MESSAGES SCREEN (Tenant & Landlord)
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Conversations",
            style: TextStyle(
              color: AppColors.allPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          children: [
            _buildChatCard("Akram Khan", "Landlord", "Your request is scheduled.", "2m ago", 2, Colors.blue),
            _buildChatCard("Sabbir Ahmed", "Plumbing Professional", "I'll arrive at 4 PM.", "1h ago", 0, Colors.green),
            _buildChatCard("Tasnim Sultana", "Property Agent", "New tenant contract is ready.", "Yesterday", 0, Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(String name, String role, String msg, String time, int unread, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: PremiumCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: color.withOpacity(0.12),
              child: Text(
                name[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    msg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: unread > 0 ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (unread > 0) ...[
              SizedBox(width: 8.w),
              CircleAvatar(
                radius: 9.r,
                backgroundColor: Colors.red,
                child: Text(
                  unread.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 3. TENANT WALLET / WALLET SCREEN (Tenant / Landlord)
class TenantWallet extends StatelessWidget {
  const TenantWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "My Wallet",
            style: TextStyle(color: AppColors.allPrimaryColor, fontWeight: FontWeight.bold, fontSize: 20.sp),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          children: [
            // Premium Virtual Card
            Container(
              height: 190.h,
              padding: EdgeInsets.all(22.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10.r,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Digital Tenant Card",
                        style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500),
                      ),
                      Icon(Icons.wifi, color: Colors.white70, size: 22.r),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "৳ 45,230.50",
                        style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Available Balance",
                        style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "FARHAN CHOWDHURY",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "09 / 29",
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Top-up and Send Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Top Up Wallet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appThemeColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.send, color: AppColors.allPrimaryColor),
                    label: Text("Transfer", style: TextStyle(color: AppColors.allPrimaryColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: AppColors.allPrimaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 26.h),

            // Transaction History Title
            Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 12.h),

            // Transaction Card List
            PremiumCard(
              child: Column(
                children: [
                  _buildTransactionRow("Rent Payment #4928", "June 01, 2026", "-৳28,500", Colors.red, Icons.receipt),
                  const Divider(height: 20),
                  _buildTransactionRow("Wallet Top Up", "May 28, 2026", "+৳15,000", Colors.green, Icons.account_balance_wallet),
                  const Divider(height: 20),
                  _buildTransactionRow("Maintenance Rebate", "May 25, 2026", "+৳2,500", Colors.green, Icons.handyman),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String title, String date, String amount, Color amountColor, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.allPrimaryColor, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 2.h),
                Text(
                  date,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: amountColor),
        ),
      ],
    );
  }
}

// 4. MY PROPERTY SCREEN
class MyPropertyScreen extends StatelessWidget {
  const MyPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "My Leases",
            style: TextStyle(color: AppColors.allPrimaryColor, fontWeight: FontWeight.bold, fontSize: 20.sp),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          children: [
            _buildPropertyCard(
              "Gulshan Premium Residency",
              "Apt 4B, Road 12, Gulshan-2, Dhaka",
              "৳ 32,000 / month",
              "Active Lease",
              Colors.green,
            ),
            _buildPropertyCard(
              "Dhanmondi Skyvilla",
              "Flat 2A, Road 4, Dhanmondi, Dhaka",
              "৳ 26,500 / month",
              "Completed Lease",
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(String title, String address, String price, String status, Color statusColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: PremiumCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cover Photo Placeholder
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.allPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Center(
                child: Icon(Icons.home_work, color: AppColors.allPrimaryColor, size: 45.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        address,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    price,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.appThemeColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. PROFILE SCREEN
class ProfileScreen extends StatelessWidget {
  final int points;
  const ProfileScreen({super.key, this.points = 100});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              children: [
                // Top Header info
                Text(
                  "Account & Security",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.allPrimaryColor),
                ),
                SizedBox(height: 24.h),

                // Avatar Container
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50.r,
                            backgroundColor: AppColors.allPrimaryColor.withOpacity(0.1),
                            child: Icon(Icons.person, size: 55.r, color: AppColors.allPrimaryColor),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundColor: AppColors.appThemeColor,
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Farhan Chowdhury",
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "farhan.chowdhury@email.com",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 26.h),

                // Points & Badges
                PremiumCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn("Safety Score", "$points/100", Colors.green),
                      Container(height: 40.h, width: 1, color: Colors.grey.shade200),
                      _buildMetricColumn("User Type", "Verified Tenant", Colors.blue),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Account Lists Settings
                PremiumCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingsTile(Icons.person_outline, "Personal Details", "Update email & name"),
                      const Divider(height: 1),
                      _buildSettingsTile(Icons.notifications_outlined, "Notification Settings", "Receive updates & bills"),
                      const Divider(height: 1),
                      _buildSettingsTile(Icons.shield_outlined, "Change Password", "Security & verification code"),
                      const Divider(height: 1),
                      _buildSettingsTile(Icons.help_outline, "Help & Support", "FAQs & raise maintenance tickets"),
                    ],
                  ),
                ),
                SizedBox(height: 26.h),

                // Log out Button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: Colors.red.shade100),
                    ),
                  ),
                  child: Text(
                    "Sign Out of Account",
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.allPrimaryColor, size: 20.r),
      ),
      title: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14.r, color: Colors.grey),
    );
  }
}

// Stubs for Landlord Dashboard Flow
class LandlordHomeScreen extends StatelessWidget {
  const LandlordHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomeScreen(); // Reused for simplicity with premium cards
  }
}

class LandlordMyPropertyScreen extends StatelessWidget {
  const LandlordMyPropertyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const MyPropertyScreen();
  }
}

class LandlordProfileScreen extends StatelessWidget {
  const LandlordProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(points: 98);
  }
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const TenantWallet();
  }
}

class MessagesLandlordScreen extends StatelessWidget {
  const MessagesLandlordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const MessagesScreen();
  }
}

// Stubs for Agent Dashboard Flow
class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class AgentProfileScreen extends StatelessWidget {
  const AgentProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(points: 95);
  }
}

// Stubs for Workman Dashboard Flow
class WorkmanHomeScreen extends StatelessWidget {
  const WorkmanHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class WorkmenProfileScreen extends StatelessWidget {
  const WorkmenProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const ProfileScreen(points: 92);
  }
}

class WorkmanJobsPendingScreen extends StatelessWidget {
  const WorkmanJobsPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Pending Jobs",
            style: TextStyle(color: AppColors.allPrimaryColor, fontWeight: FontWeight.bold, fontSize: 20.sp),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          children: [
            _buildJobCard("Plumbing leakage in Kitchen", "Dhanmondi Road 12", "Urgent", Colors.red),
            _buildJobCard("AC Servicing & Cleaning", "Gulshan-2 Road 4", "Medium", Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(String title, String loc, String priority, Color pColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(color: pColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Text(
                    priority,
                    style: TextStyle(color: pColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 14.r),
                SizedBox(width: 4.w),
                Text(loc, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      elevation: 0,
                    ),
                    child: Text("Accept Job", style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text("Decline", style: TextStyle(color: Colors.black87, fontSize: 12.sp)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 6. PROPERTY SEARCH SCREEN (Custom Search)
class PropertySearchScreen extends StatelessWidget {
  const PropertySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.allPrimaryColor),
          title: Text(
            "Search Properties",
            style: TextStyle(color: AppColors.allPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8.r, offset: const Offset(0, 4)),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Search for location, pricing...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Popular Searches",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildSearchTag("Gulshan Rent"),
                  _buildSearchTag("Dhanmondi Flat"),
                  _buildSearchTag("Studio Apartment"),
                  _buildSearchTag("Banani 3 Bed"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }
}
