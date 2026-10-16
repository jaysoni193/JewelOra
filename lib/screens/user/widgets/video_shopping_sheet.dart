import 'package:flutter/material.dart';
import 'package:jewel_ora/core/constants/app_colors.dart';
import 'package:jewel_ora/core/constants/app_sizes.dart';
import 'package:jewel_ora/core/constants/app_strings.dart';
import 'package:jewel_ora/core/utils/ui_helpers.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/models/video_appointment_model.dart';
import 'package:jewel_ora/providers/auth_provider.dart';
import 'package:jewel_ora/providers/settings_provider.dart';
import 'package:jewel_ora/providers/video_appointment_provider.dart';
import 'package:jewel_ora/services/whatsapp_service.dart';
import 'package:provider/provider.dart';

class VideoShoppingSheet extends StatefulWidget {
  const VideoShoppingSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VideoShoppingSheet(),
    );
  }

  @override
  State<VideoShoppingSheet> createState() => _VideoShoppingSheetState();
}

class _VideoShoppingSheetState extends State<VideoShoppingSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedCategory = VideoAppointmentModel.availableCategories.first;
  String _selectedLanguage = 'English';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = VideoAppointmentModel.availableTimeSlots.first;
  String _selectedPlatform = 'WhatsApp Video';

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final auth = context.read<AuthProvider>();
    _nameCtrl = TextEditingController(text: auth.user?.name ?? '');
    _phoneCtrl = TextEditingController(text: auth.user?.phone ?? '');

    // Jump to Tab 2 if there are already active appointments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appts = context.read<VideoAppointmentProvider>();
      if (appts.hasUpcoming && mounted) {
        _tabController.animateTo(1);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoAppointmentProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('📹', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.videoShopping,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.videoShoppingSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textGrey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.video_call_outlined, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.bookVideoCall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.myAppointments,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (provider.hasUpcoming) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.upcomingAppointments.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: AppColors.border),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingTab(),
                _buildMyAppointmentsTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: BOOKING FORM
  // ==========================================
  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Highlights Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.accent.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('✨', style: TextStyle(fontSize: 26)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Showroom Experience from Your Home',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Connect directly with our jewellery experts over HD video to inspect sparkle, size on hand, certificate verification, and custom design options.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Select Jewellery Interest
          Text(
            AppStrings.selectStylistTopic,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VideoAppointmentModel.availableCategories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 2. Preferred Consultation Language
          Text(
            AppStrings.consultationLanguage,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            children: VideoAppointmentModel.availableLanguages.map((lang) {
              final isSelected = _selectedLanguage == lang;
              return ChoiceChip(
                label: Text(lang),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (_) => setState(() => _selectedLanguage = lang),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 3. Select Date
          const Text(
            'Select Consultation Date',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _buildDateQuickChip('Tomorrow', DateTime.now().add(const Duration(days: 1))),
              const SizedBox(width: 8),
              _buildDateQuickChip('Day After', DateTime.now().add(const Duration(days: 2))),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.event_rounded, size: 16),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _pickCustomDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Select Time Slot
          const Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: VideoAppointmentModel.availableTimeSlots.map((slot) {
              final isSelected = _selectedSlot == slot;
              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (_) => setState(() => _selectedSlot = slot),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 5. Video Platform
          Text(
            AppStrings.videoPlatform,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: VideoAppointmentModel.availablePlatforms.map((plat) {
              final isSelected = _selectedPlatform == plat;
              final isWa = plat.contains('WhatsApp');
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isWa ? 8.0 : 0.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedPlatform = plat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isWa ? Icons.chat_rounded : Icons.video_camera_front_rounded,
                            size: 16,
                            color: isSelected ? AppColors.primary : AppColors.textGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            plat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 6. Contact Details Form
          const Text(
            'Your Contact Information',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Full Name',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number (for video call invitation)',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Specific Designs / Budget Focus (Optional)',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Action Button
          AppButton(
            title: 'Confirm Live Video Consultation',
            icon: Icons.video_call_rounded,
            onPressed: _handleConfirmBooking,
          ),
        ],
      ),
    );
  }

  Widget _buildDateQuickChip(String label, DateTime date) {
    final isSelected = _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 11,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (_) => setState(() => _selectedDate = date),
    );
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ==========================================
  // TAB 2: MY APPOINTMENTS LIST
  // ==========================================
  Widget _buildMyAppointmentsTab(VideoAppointmentProvider provider) {
    final appts = provider.upcomingAppointments;

    if (appts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.video_camera_front_outlined,
            title: AppStrings.noAppointments,
            subtitle: 'Schedule a free 1-on-1 video call to view designs and bridal sets live with a personal stylist.',
            actionLabel: AppStrings.bookVideoCall,
            onAction: () => _tabController.animateTo(0),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appts.length,
      itemBuilder: (context, index) {
        final item = appts[index];
        final days = item.daysUntil();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.categoryInterest,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Confirmed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date & Time Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${item.appointmentDate.day}/${item.appointmentDate.month}/${item.appointmentDate.year} • ${item.timeSlot}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      days == 0
                          ? 'Today!'
                          : days == 1
                              ? 'Tomorrow'
                              : '$days days to go',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Chips for Language & Platform
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildPill(Icons.language_rounded, item.preferredLanguage),
                  _buildPill(
                    item.platform.contains('WhatsApp')
                        ? Icons.chat_rounded
                        : Icons.videocam_rounded,
                    item.platform,
                  ),
                ],
              ),

              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Focus: ${item.notes}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.chat_rounded, size: 16, color: AppColors.whatsapp),
                    label: const Text(
                      'Stylist Chat',
                      style: TextStyle(
                        color: AppColors.whatsapp,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => _openStylistWhatsApp(item),
                  ),
                  TextButton(
                    onPressed: () => _confirmCancelAppointment(context, item.id),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textGrey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10, color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CONFIRM BOOKING LOGIC
  // ==========================================
  Future<void> _handleConfirmBooking() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      showAppSnackBar(context, 'Please enter your name.', isError: true);
      return;
    }
    if (phone.isEmpty) {
      showAppSnackBar(context, 'Please enter your phone number.', isError: true);
      return;
    }

    final newAppt = VideoAppointmentModel(
      id: 'VSA-${DateTime.now().millisecondsSinceEpoch}',
      customerName: name,
      customerPhone: phone,
      categoryInterest: _selectedCategory,
      preferredLanguage: _selectedLanguage,
      appointmentDate: _selectedDate,
      timeSlot: _selectedSlot,
      platform: _selectedPlatform,
      notes: _notesCtrl.text.trim(),
      status: 'confirmed',
      createdAt: DateTime.now(),
    );

    await context.read<VideoAppointmentProvider>().bookAppointment(newAppt);

    _tabController.animateTo(1);
    if (mounted) {
      showAppSnackBar(
        context,
        '🎉 Video shopping consultation booked successfully for ${_selectedDate.day}/${_selectedDate.month}!',
      );
    }

    // Launch WhatsApp invitation ping to store
    _sendWhatsAppBookingNotice(newAppt);
  }

  void _sendWhatsAppBookingNotice(VideoAppointmentModel appt) async {
    final settings = context.read<SettingsProvider>();
    final storePhone = settings.settings.whatsappNumber;

    final msg = StringBuffer()
      ..writeln('Namaste Jewel Ora team, 📹')
      ..writeln('I have booked a Virtual Live Video Shopping consultation:')
      ..writeln()
      ..writeln('• Booking ID: ${appt.id}')
      ..writeln('• Customer Name: ${appt.customerName}')
      ..writeln('• Phone: ${appt.customerPhone}')
      ..writeln('• Category Interest: ${appt.categoryInterest}')
      ..writeln('• Language: ${appt.preferredLanguage}')
      ..writeln('• Date: ${appt.appointmentDate.day}/${appt.appointmentDate.month}/${appt.appointmentDate.year}')
      ..writeln('• Time Slot: ${appt.timeSlot}')
      ..writeln('• Platform: ${appt.platform}')
      ..writeln(appt.notes.isNotEmpty ? '• Special Focus: ${appt.notes}' : '')
      ..writeln()
      ..writeln('Looking forward to seeing the pieces live!');

    try {
      await WhatsAppService.open(
        phone: storePhone,
        message: msg.toString(),
      );
    } catch (_) {}
  }

  void _openStylistWhatsApp(VideoAppointmentModel appt) async {
    final settings = context.read<SettingsProvider>();
    final storePhone = settings.settings.whatsappNumber;

    final msg = StringBuffer()
      ..writeln('Hello Jewel Ora Stylist, 📹')
      ..writeln('Regarding my upcoming video consultation #${appt.id} on ${appt.appointmentDate.day}/${appt.appointmentDate.month} (${appt.timeSlot}):')
      ..writeln('Category: ${appt.categoryInterest}');

    try {
      await WhatsAppService.open(
        phone: storePhone,
        message: msg.toString(),
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  void _confirmCancelAppointment(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Video Consultation'),
        content: const Text(
          'Are you sure you want to cancel this video consultation? You can reschedule anytime.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await context.read<VideoAppointmentProvider>().cancelAppointment(id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                showAppSnackBar(context, 'Consultation cancelled.');
              }
            },
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }
}
