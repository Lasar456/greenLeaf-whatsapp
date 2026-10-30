import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// GreenLeaf Clean Campaigns — fully native Flutter UI preview.
// This app contains ONLY sample/demo data, does not use WebView,
// and cannot send real WhatsApp messages or charge money.

const dark = Color(0xFF181727);
const ink = Color(0xFF1A1B24);
const muted = Color(0xFF888995);
const canvas = Color(0xFFF0EFF4);
const purple = Color(0xFF9164E5);
const lime = Color(0xFFBCF14A);
const green = Color(0xFF13A768);
const navy = Color(0xFF37294F);
const line = Color(0xFFE7E5ED);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: dark,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: canvas,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const GreenLeafApp());
}

class GreenLeafApp extends StatelessWidget {
  const GreenLeafApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GreenLeaf',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(seedColor: green, surface: canvas),
      splashFactory: InkRipple.splashFactory,
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: InputBorder.none,
      ),
    ),
    home: const GreenLeafShell(),
  );
}

class Campaign {
  final String name, template, status;
  final int recipients, sent, delivered, read, failed, progress;
  const Campaign(this.name, this.template, this.status, this.recipients,
      this.sent, this.delivered, this.read, this.failed, this.progress);
}

const demoCampaigns = [
  Campaign('Utility follow-up', 'Utility template', 'In progress', 951, 292, 219, 18, 238, 56),
  Campaign('Marketing campaign', 'Marketing template', 'In progress', 958, 382, 308, 21, 576, 91),
  Campaign('Welcome message', 'Utility template', 'Completed', 148, 146, 139, 61, 2, 100),
];

class DemoChat {
  final String name, preview, time, assignment;
  final int unread;
  const DemoChat(this.name, this.preview, this.time, this.assignment, this.unread);
}

const demoChats = [
  DemoChat('Customer 01', 'Hi, is the spa available today?', '10:32 AM', 'Unassigned', 2),
  DemoChat('Customer 02', 'Thank you! Please share the price.', '09:58 AM', 'Assigned to you', 0),
  DemoChat('Customer 03', "I\u0027d like to know about the services.", 'Yesterday', 'Unassigned', 1),
  DemoChat('Customer 04', 'Appointment confirmed for tomorrow.', 'Yesterday', 'Assigned to you', 0),
];

class DemoLead {
  final String name, consent;
  const DemoLead(this.name, this.consent);
}
const demoLeads = [
  DemoLead('Customer 01', 'Subscribed'),
  DemoLead('Customer 02', 'No opt-in'),
  DemoLead('Customer 03', 'Unsubscribed'),
  DemoLead('Customer 04', 'Subscribed'),
  DemoLead('Customer 05', 'No opt-in'),
];

class GreenLeafShell extends StatefulWidget {
  const GreenLeafShell({super.key});
  @override
  State<GreenLeafShell> createState() => _GreenLeafShellState();
}

class _GreenLeafShellState extends State<GreenLeafShell> {
  int tab = 0;
  bool billingOpen = false;
  bool headerVisible = true;
  double lastOffset = 0;
  String campaignFilter = 'All', chatFilter = 'All', leadFilter = 'All';
  String campaignSearch = '', chatSearch = '', leadSearch = '';
  int chartMonths = 6;
  String billingTab = 'Plans', billingPeriod = 'Monthly';
  final Set<String> expandedPlans = {};
  final Set<String> expandedHistory = {};
  final List<ScrollController> _controllers = List.generate(5, (_) => ScrollController());

  @override
  void dispose() {
    for (final controller in _controllers) {controller.dispose();}
    super.dispose();
  }

  void go(int next) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (next != tab || billingOpen) {
      setState(() {tab = next; billingOpen = false; headerVisible = true; lastOffset = 0;});
      if (_controllers[next].hasClients) _controllers[next].jumpTo(0);
    }
  }

  void openBilling() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {tab = 4; billingOpen = true; billingTab = 'Plans'; headerVisible = true;});
    if (_controllers[4].hasClients) _controllers[4].jumpTo(0);
  }

  void info(String title, String description) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => SafeArea(top: false, child: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 34, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(3)))),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 13, height: 1.6, color: muted)),
            const SizedBox(height: 22),
            SizedBox(width: double.infinity, height: 45, child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: dark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pop(ctx), child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)))),
          ],
        ),
      )),
    );
  }

  void infoKey(String key) {
    const descriptions = <String, (String, String)>{
      'wallet': ('Wallet', 'The ₹1000 balance shown in the header is illustrative, not a live wallet value.'),
      'workspace': ('Current workspace', 'Luxe Lavender Salon & Spa is the selected demo workspace.'),
      'Agents': ('Agents & assignments', 'In the connected app, agents and conversation assignments appear here.'),
      'Templates': ('Message templates', 'Approved templates, media previews, and template status appear here in the connected app.'),
      'Meta Ads': ('Meta Ads', 'Meta lead campaigns are not connected in this demonstration.'),
      'Workflow': ('Workflows', 'This is a design-only preview of workflow navigation.'),
      'reports': ('Messaging reports', 'These charts use illustrative numbers, not live message events.'),
      'New': ('Create a campaign', 'In the connected app, create a template campaign and select recipients with consent checks.'),
      'Import': ('Import contacts', 'Imported contacts should not automatically be marked as marketing opted-in.'),
      'WhatsApp API settings': ('WhatsApp API settings', 'Connected account information and webhook settings appear here in the production app.'),
      'Privacy & security': ('Privacy & security', 'Workspace permissions and privacy controls appear here in the production app.'),
    };
    final entry = descriptions[key] ?? (key, 'This feature is a design preview; no live operation was performed.');
    info(entry.$1, entry.$2);
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && notification.depth == 0) {
      final offset = notification.metrics.pixels;
      // Match source: header remains hidden while scrolling up, until top.
      if (offset <= 2 && !headerVisible) {setState(() => headerVisible = true);}
      else if (offset > 45 && offset > lastOffset + 2 && headerVisible) {
        setState(() => headerVisible = false);
      }
      lastOffset = offset;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _home(), _campaigns(), _inbox(), _contacts(), billingOpen ? _billing() : _more(),
    ];
    return WillPopScope(
      onWillPop: () async {
        if (billingOpen) {setState(() {billingOpen = false; headerVisible = true;}); return false;}
        if (tab != 0) {go(0); return false;}
        return true;
      },
      child: Scaffold(
        body: ColoredBox(color: dark, child: SafeArea(bottom: false, child: ColoredBox(color: canvas, child: Column(children: [
          SizedBox(height: 78, child: Stack(children: [
            const ColoredBox(color: dark, child: SizedBox.expand()),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              opacity: headerVisible ? 1 : 0,
              child: _header(),
            ),
          ])),
          Expanded(child: NotificationListener<ScrollNotification>(
            onNotification: _handleScroll,
            child: IndexedStack(index: tab, children: [
              for (var i = 0; i < 5; i++) _scrollScreen(i, screens[i]),
            ]),
          )),
        ])))),
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  Widget _scrollScreen(int i, Widget child) => SingleChildScrollView(
    key: PageStorageKey('screen-$i'), controller: _controllers[i],
    physics: const ClampingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(17, 14, 17, 26), child: child,
  );

  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
    decoration: const BoxDecoration(color: dark,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(17))),
    child: Row(children: [
      Expanded(child: GestureDetector(
        onTap: () => infoKey('workspace'), behavior: HitTestBehavior.opaque,
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Luxe Lavender', style: TextStyle(fontSize: 19.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -.55)),
            SizedBox(height: 4),
            Row(children: [Text('SALON & SPA', style: TextStyle(fontSize: 10, letterSpacing: .9, color: Color(0xFFDAD8E6), fontWeight: FontWeight.w600)),
              SizedBox(width: 4), Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white70)]),
          ],
        ),
      )),
      InkWell(onTap: () => infoKey('wallet'), borderRadius: BorderRadius.circular(22), child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(width: 38, height: 39, margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: const Color(0xFF272536), shape: BoxShape.circle,
              border: Border.all(color: Colors.white24)),
            child: const Icon(Icons.payments_rounded, size: 21, color: lime)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF272536), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24)),
            child: const Text('₹1000', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white))),
        ],
      )),
      const SizedBox(width: 9),
      InkWell(onTap: () => go(4), borderRadius: BorderRadius.circular(25), child: Container(
        width: 35, height: 35, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF252432)),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 22))),
    ]),
  );

  Widget _bottomNav() => SafeArea(
    top: false,
    minimum: EdgeInsets.zero,
    child: Container(
      height: 61, decoration: const BoxDecoration(color: Color(0xFFFBFBFE),
        border: Border(top: BorderSide(color: line))),
      padding: const EdgeInsets.fromLTRB(7, 4, 7, 3),
      child: Row(children: [
        _navItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
        _navItem(1, 'Campaigns', Icons.send_outlined, Icons.send_rounded),
        _navItem(2, 'Inbox', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, unread: 3),
        _navItem(3, 'Contacts', Icons.people_alt_outlined, Icons.people_alt_rounded),
        _navItem(4, 'More', Icons.more_horiz_rounded, Icons.more_horiz_rounded),
      ]),
    ),
  );

  Widget _navItem(int index, String name, IconData normal, IconData activeIcon, {int unread = 0}) {
    final selected = tab == index;
    return Expanded(child: InkWell(
      onTap: () => go(index), borderRadius: BorderRadius.circular(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(clipBehavior: Clip.none, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 43, height: 29, alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE1E0E8) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: selected ? Border.all(color: const Color(0xFFE1DFE8)) : null,
            ),
            child: Icon(selected ? activeIcon : normal, size: 21,
              color: selected ? dark : const Color(0xFF8E899B)),
          ),
          if (unread > 0) Positioned(right: -2, top: -5, child: Container(
            width: 16, height: 16, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFFF6376), shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.3)),
            child: Text('$unread', style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800)))),
        ]),
        const SizedBox(height: 2),
        Text(name, style: TextStyle(fontSize: 9.4, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? dark : const Color(0xFF8F8B9A))),
      ]),
    ));
  }

  Widget _home() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Expanded(child: Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFE8F8ED), borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 7, color: Color(0xFF20BD6A)), SizedBox(width: 6),
          Text('Connected', style: TextStyle(color: Color(0xFF128052), fontSize: 10, fontWeight: FontWeight.w700))])),
    ]),
    const SizedBox(height: 13),
    Row(children: [
      Expanded(child: _kpi('Messages sent', '2,988', Icons.send_outlined, purple, 'Meta sent', purple)),
      const SizedBox(width: 9),
      Expanded(child: _kpi('Delivered', '2,720', Icons.done_all_rounded, green, 'Delivered', lime)),
    ]),
    const SizedBox(height: 9),
    Row(children: [
      Expanded(child: _kpi('Read', '743', Icons.visibility_outlined, const Color(0xFF6198E0), 'Opened', navy)),
      const SizedBox(width: 9),
      Expanded(child: _kpi('Failed', '1,611', Icons.error_outline, const Color(0xFFE98578), 'Failed', const Color(0xFFEB8166))),
    ]),
    _section('Quick actions'),
    Row(children: [
      _quick('Agents', Icons.support_agent_rounded),
      const SizedBox(width: 8), _quick('Templates', Icons.description_outlined),
      const SizedBox(width: 8), _quick('Meta Ads', Icons.all_inclusive_rounded),
      const SizedBox(width: 8), _quick('Workflow', Icons.account_tree_outlined),
    ]),
    _section('Messaging performance', subtitle: 'Monthly message activity', action: 'Details', onAction: () => infoKey('reports')),
    _chartPanel(),
    _section('Recent campaigns', action: 'View all', onAction: () => go(1)),
    _campaignCard(demoCampaigns[0]),
    const SizedBox(height: 9),
    _campaignCard(demoCampaigns[1]),
    _section('Support inbox'),
    Container(width: double.infinity, padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: const Color(0xFF151E1C), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Active conversations', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          SizedBox(height: 8), Text('416', style: TextStyle(fontSize: 31, color: Colors.white)),
          Text('Customer conversations', style: TextStyle(color: Color(0xFFB4C4C0), fontSize: 10)),
        ])),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: dark,
          padding: const EdgeInsets.symmetric(horizontal: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
          onPressed: () => go(2), child: const Text('Open inbox ↗', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
      ]),
    ),
  ]);

  Widget _kpi(String label, String number, IconData icon, Color color, String pill, Color pillColor) =>
    GlassCard(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: muted))),
        Icon(icon, color: color, size: 17)]),
      const SizedBox(height: 13),
      Text(number, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w500, letterSpacing: -.9, color: ink)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(5)),
        child: Text(pill, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
          color: pillColor == lime ? dark : Colors.white))),
    ]));

  Widget _quick(String name, IconData icon) => Expanded(child: GlassCard(
    padding: EdgeInsets.zero,
    child: InkWell(onTap: () => infoKey(name), borderRadius: BorderRadius.circular(15),
      child: SizedBox(height: 87, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 34, height: 34,
          decoration: BoxDecoration(color: const Color(0xFFE7E6EB), borderRadius: BorderRadius.circular(11)),
          alignment: Alignment.center, child: Icon(icon, color: dark, size: 22)),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 10.2, fontWeight: FontWeight.w600, color: ink), maxLines: 1),
      ])),
    ),
  ));

  Widget _section(String title, {String? subtitle, String? action, VoidCallback? onAction}) => Padding(
    padding: const EdgeInsets.only(top: 23, bottom: 11),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.w700)),
        if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(color: muted, fontSize: 10))),
      ])),
      if (action != null) TextButton(onPressed: onAction,
        style: TextButton.styleFrom(foregroundColor: muted, padding: const EdgeInsets.symmetric(horizontal: 3)),
        child: Row(children: [Text(action, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 3), const Icon(Icons.arrow_forward_ios_rounded, size: 10)])),
    ]),
  );

  Widget _chartPanel() {
    const data = <(String,int,int,int,int)>[
      ('Nov',580,542,130,59),('Dec',620,578,143,67),('Jan',665,617,148,61),
      ('Feb',704,663,175,52),('Mar',730,699,159,79),('Apr',780,726,180,73),
      ('May',720,680,152,55),('Jun',805,748,175,65),('Jul',922,860,210,81),
      ('Aug',1050,1000,240,91),('Sep',870,795,190,62),('Oct',1180,1100,309,110),
    ];
    final view = data.sublist(data.length-chartMonths);
    return GlassCard(padding: const EdgeInsets.all(15), child: Column(children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Monthly overview', style: TextStyle(fontSize: 15, color: ink, fontWeight: FontWeight.w700)),
          SizedBox(height: 4), Text('Message activity by month', style: TextStyle(fontSize: 10, color: muted)),
        ])),
        _miniSwitch(['6M', '12M'], chartMonths == 6 ? '6M' : '12M', (v) => setState(() => chartMonths = v == '6M' ? 6 : 12)),
      ]),
      const SizedBox(height: 22),
      SizedBox(height: 137, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final d in view) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Column(children: [
            Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
              _chartBar(d.$2, purple, chartMonths == 6 ? 6 : 3),
              _chartBar(d.$3, lime, chartMonths == 6 ? 6 : 3),
              _chartBar(d.$4, const Color(0xFF7EAEED), chartMonths == 6 ? 6 : 3),
              _chartBar(d.$5, const Color(0xFFF2968C), chartMonths == 6 ? 6 : 3),
            ])),
            const SizedBox(height: 9),
            Text(d.$1, style: TextStyle(fontSize: chartMonths == 6 ? 9 : 7, color: muted)),
          ]))),
      ])),
      const SizedBox(height: 17),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _legend('Sent',purple),_legend('Delivered',lime),
        _legend('Read',const Color(0xFF7EAEED)),_legend('Failed',const Color(0xFFF2968C)),
      ]),
      const SizedBox(height: 13),
      const Row(children: [Icon(Icons.circle, size: 6, color: lime), SizedBox(width: 6),
        Expanded(child: Text('Demo monthly data · Reporting integration required',
          style: TextStyle(fontSize: 9.5, color: muted)))]),
    ]));
  }

  Widget _chartBar(int v, Color c, double width) => Container(
    height: 113*v/1300, width: width,
    margin: const EdgeInsets.symmetric(horizontal: .6),
    decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
  );
  Widget _legend(String label, Color c) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 9, color: muted))]);

  Widget _campaignCard(Campaign c) => GlassCard(padding: const EdgeInsets.all(14), child: Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, color: ink, fontSize: 12.5)),
        const SizedBox(height: 5),
        Text('${c.recipients} recipients · ${c.template}', style: const TextStyle(fontSize: 10, color: muted)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: c.status == 'Completed' ? const Color(0xFFE8F8ED) : const Color(0xFFFFF4DD),
          borderRadius: BorderRadius.circular(8)),
        child: Text(c.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
          color: c.status == 'Completed' ? green : const Color(0xFFB57A23)))),
    ]),
    const SizedBox(height: 15),
    Row(children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
        value: c.progress/100, minHeight: 7,
        backgroundColor: const Color(0xFFE7E5EA), valueColor: const AlwaysStoppedAnimation<Color>(purple)))),
      const SizedBox(width: 10),
      Text('${c.progress}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ink)),
    ]),
    const SizedBox(height: 14),
    const Divider(color: line, height: 1),
    const SizedBox(height: 11),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _metric('Sent', c.sent), _metric('Delivered', c.delivered),
      _metric('Read', c.read), _metric('Failed', c.failed),
    ]),
  ]));

  Widget _metric(String name, int count) => Column(children: [
    Text('$count', style: const TextStyle(fontSize: 13, color: ink, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5),
    Text(name, style: const TextStyle(fontSize: 9, color: muted)),
  ]);

  Widget _search(String hint, ValueChanged<String> onChanged) => Container(
    height: 44,
    margin: const EdgeInsets.only(top: 11, bottom: 13),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.78), border: Border.all(color: line),
      borderRadius: BorderRadius.circular(13)),
    child: TextField(onChanged: onChanged, style: const TextStyle(color: ink, fontSize: 12),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded, color: muted, size: 19),
        hintText: hint, hintStyle: const TextStyle(color: muted, fontSize: 12))),
  );

  Widget _filter(List<String> options, String selected, ValueChanged<String> onChanged) =>
    Container(margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFE4E2EA), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [for (final option in options) Expanded(child: InkWell(
        borderRadius: BorderRadius.circular(9), onTap: () => onChanged(option),
        child: AnimatedContainer(duration: const Duration(milliseconds: 120),
          alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: option == selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: option == selected ? [const BoxShadow(color: Color(0x10000000), blurRadius: 3)] : null),
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(option, style: TextStyle(fontSize: 10.5,
            fontWeight: option == selected ? FontWeight.w700 : FontWeight.w500,
            color: option == selected ? ink : muted)))),
      ))]),
    );

  Widget _titleRow(String title, {String? action, VoidCallback? onTap, String? counter}) =>
    Row(children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 24, color: ink, fontWeight: FontWeight.w700, letterSpacing: -.6))),
      if (counter != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFE8F8ED), borderRadius: BorderRadius.circular(9)),
        child: Text(counter, style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w700))),
      if (action != null) FilledButton.icon(onPressed: onTap,
        style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: dark,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        icon: Icon(action == 'Import' ? Icons.file_upload_outlined : Icons.add_rounded, size: 15),
        label: Text(action, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
    ]);

  Widget _campaigns() {
    final filtered = demoCampaigns.where((c) =>
      (campaignFilter == 'All' || c.status == campaignFilter) &&
      c.name.toLowerCase().contains(campaignSearch.toLowerCase().trim())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _titleRow('Campaigns', action: 'New', onTap: () => infoKey('New')),
      _search('Search campaigns', (v) => setState(() => campaignSearch = v)),
      _filter(['All', 'In progress', 'Completed'], campaignFilter, (v) => setState(() => campaignFilter = v)),
      ...filtered.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _campaignCard(c))),
      if (filtered.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(25), child: Text('No campaigns found', style: TextStyle(color: muted)))),
    ]);
  }

  Widget _inbox() {
    final filtered = demoChats.where((c) =>
      (chatFilter == 'All' || (chatFilter == 'Unassigned' && c.assignment == 'Unassigned') ||
      (chatFilter == 'Assigned to me' && c.assignment == 'Assigned to you')) &&
      (c.name + c.preview).toLowerCase().contains(chatSearch.toLowerCase().trim())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _titleRow('Inbox', counter: '416 active'),
      _search('Search conversations', (v) => setState(() => chatSearch = v)),
      _filter(['All', 'Unassigned', 'Assigned to me'], chatFilter, (v) => setState(() => chatFilter = v)),
      GlassCard(padding: EdgeInsets.zero, child: Column(children: [
        for (var i = 0; i < filtered.length; i++) ...[
          InkWell(onTap: () => _openChat(filtered[i]), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(children: [
              _customerAvatar(filtered[i].name, 39), const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(filtered[i].name, style: const TextStyle(fontSize: 12.5, color: ink, fontWeight: FontWeight.w700))),
                  Text(filtered[i].time, style: const TextStyle(fontSize: 9.5, color: muted))]),
                const SizedBox(height: 4),
                Text(filtered[i].preview, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 11)),
                const SizedBox(height: 5),
                Row(children: [Expanded(child: Text(filtered[i].assignment, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted))),
                  if (filtered[i].unread > 0) Container(width: 18, height: 18,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1FC76C)), alignment: Alignment.center,
                    child: Text('${filtered[i].unread}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)))])
              ])),
            ]),
          )),
          if (i < filtered.length-1) const Divider(height: 1, color: line, indent: 13, endIndent: 13),
        ],
        if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(25), child: Text('No conversations found', style: TextStyle(color: muted))),
      ])),
    ]);
  }

  Widget _customerAvatar(String name, double size) => Container(width: size, height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: const Color(0xFFE9E6F1), borderRadius: BorderRadius.circular(size*.32)),
    child: const Icon(Icons.person_rounded, color: Color(0xFF75658F), size: 24));

  void _openChat(DemoChat chat) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(context, MaterialPageRoute(builder: (_) => DemoConversation(chat: chat)));
  }

  Widget _contacts() {
    final filtered = demoLeads.where((l) =>
      (leadFilter == 'All' || l.consent == leadFilter) &&
      l.name.toLowerCase().contains(leadSearch.toLowerCase().trim())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _titleRow('Contacts', action: 'Import', onTap: () => infoKey('Import')),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: GlassCard(padding: const EdgeInsets.all(14), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('12', style: TextStyle(fontSize: 24, color: ink, fontWeight: FontWeight.w600)),
          SizedBox(height: 5), Text('Saved contacts', style: TextStyle(fontSize: 10, color: muted)),
        ]))),
        const SizedBox(width: 9),
        Expanded(child: GlassCard(padding: const EdgeInsets.all(14), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('416', style: TextStyle(fontSize: 24, color: ink, fontWeight: FontWeight.w600)),
          SizedBox(height: 5), Text('Conversations', style: TextStyle(fontSize: 10, color: muted)),
        ]))),
      ]),
      _search('Search contacts', (v) => setState(() => leadSearch = v)),
      _filter(['All', 'Subscribed', 'Unsubscribed'], leadFilter, (v) => setState(() => leadFilter = v)),
      GlassCard(padding: EdgeInsets.zero, child: Column(children: [
        for (var i = 0; i < filtered.length; i++) ...[
          Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12), child: Row(children: [
            _customerAvatar(filtered[i].name, 37), const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(filtered[i].name, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4), const Text('WhatsApp contact', style: TextStyle(color: muted, fontSize: 10)),
            ])),
            _consentBadge(filtered[i].consent),
          ])),
          if (i < filtered.length-1) const Divider(height: 1, color: line, indent: 12, endIndent: 12),
        ],
        if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No contacts found', style: TextStyle(color: muted))),
      ])),
      const SizedBox(height: 13),
      const Text('Consent badges are demonstration statuses, not verified customer records.',
        style: TextStyle(fontSize: 10, color: muted, height: 1.5)),
    ]);
  }

  Widget _consentBadge(String status) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: status == 'Subscribed' ? const Color(0xFFE8F8ED) :
      status == 'Unsubscribed' ? const Color(0xFFFFEDED) : const Color(0xFFF0EFF4),
      borderRadius: BorderRadius.circular(7)),
    child: Text(status, style: TextStyle(fontSize: 9.3, fontWeight: FontWeight.w600,
      color: status == 'Subscribed' ? const Color(0xFF128052) :
        status == 'Unsubscribed' ? const Color(0xFFCF7474) : muted)));

  Widget _more() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _titleRow('More'),
    const Padding(padding: EdgeInsets.only(top: 17, bottom: 10), child: Text('ACCOUNT',
      style: TextStyle(fontSize: 10, color: muted, letterSpacing: 1.1, fontWeight: FontWeight.w700))),
    GlassCard(padding: EdgeInsets.zero, child: Column(children: [
      _moreLink('Plan & billing', Icons.credit_card_rounded, openBilling),
      const Divider(height: 1, color: line),
      _moreLink('WhatsApp API settings', Icons.settings_outlined, () => infoKey('WhatsApp API settings')),
      const Divider(height: 1, color: line),
      _moreLink('Privacy & security', Icons.verified_user_outlined, () => infoKey('Privacy & security')),
    ])),
  ]);

  Widget _moreLink(String title, IconData icon, VoidCallback tap) => InkWell(onTap: tap,
    borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(13),
      child: Row(children: [
        Container(width: 33, height: 33, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFF0EFF3), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: dark, size: 19)),
        const SizedBox(width: 12), Expanded(child: Text(title, style: const TextStyle(color: ink, fontSize: 12.5, fontWeight: FontWeight.w600))),
        const Icon(Icons.chevron_right_rounded, size: 20, color: muted),
      ])));

  Widget _billing() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      InkWell(onTap: () => setState(() => billingOpen = false), child: Container(
        width: 35, height: 35, alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: line)),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: ink))),
      const SizedBox(width: 10),
      const Expanded(child: Text('Billing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: ink))),
      const Text('My account', style: TextStyle(color: muted, fontSize: 10)),
    ]),
    const SizedBox(height: 14),
    if (billingTab == 'Plans') ...[
      Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2C233E), Color(0xFF4D3278)]),
          borderRadius: BorderRadius.circular(19)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.workspace_premium_outlined, size: 15, color: Color(0xFFDCC8FE)),
            SizedBox(width: 8), Text('YOUR MEMBERSHIP', style: TextStyle(fontSize: 10, letterSpacing: 1.1, color: Color(0xFFCEC1DF)))]),
          const SizedBox(height: 17),
          const Row(children: [Text('Basic', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w700)),
            SizedBox(width: 10), Chip(label: Text('Active · Monthly', style: TextStyle(fontSize: 10, color: Colors.white)),
              visualDensity: VisualDensity.compact, backgroundColor: Color(0xFF765BA7),
              side: BorderSide.none)]),
          const SizedBox(height: 5),
          const Text('Your GreenLeaf subscription', style: TextStyle(fontSize: 11, color: Color(0xFFC5B8DA))),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x44FFFFFF)),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RENEWS / VALID UNTIL', style: TextStyle(fontSize: 9, color: Color(0xFFC6B9DB))),
              SizedBox(height: 5), Text('09 Nov 2026', style: TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(height: 2), Text('11 days left · Demo', style: TextStyle(fontSize: 9.5, color: Color(0xFFC6B9DB))),
            ])),
            FilledButton(style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: dark,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
              onPressed: () => setState(() => billingTab = 'Plans'),
              child: const Text('Manage plan', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700))),
          ]),
        ]),
      ),
      const SizedBox(height: 11),
      Row(children: [
        Expanded(child: GlassCard(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.toll_outlined, color: purple, size: 17), SizedBox(width: 6),
            Expanded(child: Text('Token balance', style: TextStyle(fontSize: 10, color: muted)))]),
          const SizedBox(height: 15),
          const Text('486.64', style: TextStyle(fontSize: 25, color: ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5), const Text('Available messaging tokens', style: TextStyle(color: muted, fontSize: 9.5)),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () => _billingAction('Buy tokens'),
            child: const Text('Top up ↗', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.w700)))),
        ]))),
        const SizedBox(width: 9),
        Expanded(child: GlassCard(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.bar_chart_rounded, color: purple, size: 17), SizedBox(width: 6),
            Expanded(child: Text('Monthly usage', style: TextStyle(fontSize: 10, color: muted)))]),
          const SizedBox(height: 15),
          const Text('3,278', style: TextStyle(fontSize: 25, color: ink, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5), const Text('of 10,000 templates', style: TextStyle(color: muted, fontSize: 9.5)),
          const SizedBox(height: 26),
          const LinearProgressIndicator(value: .328, minHeight: 5,
            backgroundColor: Color(0xFFEDEAF2), color: purple),
        ]))),
      ]),
      const SizedBox(height: 14),
    ],
    _filter(['Plans', 'Add-ons', 'Activity'], billingTab, (v) {
      setState(() => billingTab = v);
      if (_controllers[4].hasClients) _controllers[4].jumpTo(0);
    }),
    if (billingTab == 'Plans') _billingPlans(),
    if (billingTab == 'Add-ons') _billingAddons(),
    if (billingTab == 'Activity') _billingActivity(),
  ]);

  Widget _billingPlans() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Expanded(child: Text('Choose your plan', style: TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w700))),
      _miniSwitch(['Monthly','Quarterly','Yearly'], billingPeriod, (v) => setState(() => billingPeriod = v)),
    ]),
    const SizedBox(height: 13),
    _plan('Basic', '₹1,500', '10k templates', '3 agents', '1 workflow', true),
    const SizedBox(height: 9),
    _plan('Premium', '₹3,200', 'Unlimited templates', '5 agents', '3 workflows', false),
    const SizedBox(height: 9),
    _plan('Pro', '₹9,100', 'Unlimited templates', '10 agents', '5 workflows', false),
    const SizedBox(height: 11),
    GlassCard(padding: EdgeInsets.zero, child: ListTile(onTap: () => _billingAction('Message token rates'),
      leading: const Icon(Icons.payments_outlined, color: dark, size: 20),
      title: const Text('Message token rates', style: TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded, color: dark))),
  ]);

  Widget _plan(String name, String price, String volume, String agents, String workflows, bool current) {
    final expanded = expandedPlans.contains(name);
    return GlassCard(padding: const EdgeInsets.all(14), child: Column(children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: ink)),
          if (current) ...[const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(5)),
            child: const Text('CURRENT PLAN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)))],
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: ink)),
          const Text('per month', style: TextStyle(fontSize: 9, color: muted)),
        ]),
      ]),
      const SizedBox(height: 13),
      Wrap(spacing: 5, runSpacing: 5, children: [volume,agents,workflows].map((x) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFF0EFF4), borderRadius: BorderRadius.circular(6)),
        child: Text(x, style: const TextStyle(fontSize: 9.5, color: Color(0xFF706A79))))).toList()),
      const SizedBox(height: 10),
      InkWell(onTap: () => setState(() => expanded ? expandedPlans.remove(name) : expandedPlans.add(name)),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
          const Expanded(child: Text("What's included", style: TextStyle(fontSize: 10.5, color: muted))),
          Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 18, color: muted),
        ]))),
      if (expanded) ...[
        _planFeature('Unlimited saved contacts'),
        _planFeature('First 1,000 service replies free each month, then plan token rate'),
        _planFeature('50 included tokens'),
      ],
      const SizedBox(height: 5),
      SizedBox(width: double.infinity, height: 38, child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: current ? navy : lime,
          foregroundColor: current ? Colors.white : dark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        onPressed: () => _billingAction(current ? 'Extend Basic' : 'Switch to $name'),
        child: Text(current ? 'Extend current plan' : 'Switch to $name',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
      )),
    ]));
  }

  Widget _planFeature(String text) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [
    const Icon(Icons.check, size: 15, color: purple), const SizedBox(width: 6),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 10, color: muted))),
  ]));

  Widget _billingAddons() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Grow your workspace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
    const SizedBox(height: 5), const Text('More capacity, whenever you need it', style: TextStyle(fontSize: 10, color: muted)),
    const SizedBox(height: 15),
    _addon('Workflow slots', '0 of 1 active slots used',
      'One workflow slot is included in your plan.', 'Add slot', 'Add workflow slot'),
    const SizedBox(height: 9),
    _addon('Team seats', '1 of 3 agent seats used',
      'Your plan includes three team seats.', 'Add seat', 'Add agent seat'),
  ]);

  Widget _addon(String title, String count, String detail, String button, String action) =>
    GlassCard(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.add_box_outlined, color: purple, size: 21), const SizedBox(width: 9),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: ink, fontSize: 13))]),
      const SizedBox(height: 10), Text(count, style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 9), Text(detail, style: const TextStyle(color: muted, fontSize: 10)),
      const SizedBox(height: 14),
      Row(children: [const Expanded(child: Text('₹500 / month per extra', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: ink))),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: lime, foregroundColor: dark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () => _billingAction(action), child: Text('+ $button', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))]),
    ]));

  Widget _billingActivity() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Account activity', style: TextStyle(fontSize: 16, color: ink, fontWeight: FontWeight.w700)),
    const SizedBox(height: 5),
    const Text('Payments and messaging token usage', style: TextStyle(fontSize: 10, color: muted)),
    const SizedBox(height: 15),
    _history('Payments', '0 recent transactions',
      'No payment records are available in this preview.'),
    const SizedBox(height: 10),
    _history('Token usage', '24 recent usage entries',
      'Your reference indicates 24 recent usage entries. Detailed usage will appear when connected.'),
  ]);

  Widget _history(String title, String description, String body) => GlassCard(
    padding: EdgeInsets.zero, child: Column(children: [
      InkWell(onTap: () => setState(() => expandedHistory.contains(title) ? expandedHistory.remove(title) : expandedHistory.add(title)),
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          const Icon(Icons.receipt_long_outlined, color: purple, size: 22), const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 4), Text(description, style: const TextStyle(fontSize: 10, color: muted)),
          ])),
          Icon(expandedHistory.contains(title) ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: muted),
        ]))),
      if (expandedHistory.contains(title)) Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Text(body, style: const TextStyle(fontSize: 10.5, color: muted, height: 1.5))),
    ]));

  Widget _miniSwitch(List<String> options, String selected, ValueChanged<String> onChanged) =>
    Container(padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xFFE8E6ED), borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [for (final o in options) InkWell(
        borderRadius: BorderRadius.circular(7), onTap: () => onChanged(o),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(color: selected == o ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7)),
          child: Text(o, style: TextStyle(color: selected == o ? dark : muted,
            fontSize: 9.5, fontWeight: selected == o ? FontWeight.w700 : FontWeight.w500))),
      )]),
    );

  void _billingAction(String action) {
    final descriptions = <String, String>{
      'Buy tokens': 'Token purchase is not enabled in this preview. No payment will be collected.',
      'Message token rates': 'The supplied reference lists ₹1.05 per token on the Basic plan. Actual rates depend on your connected billing configuration.',
      'Extend Basic': 'The Basic plan is displayed as a sample. No subscription is extended or charged.',
      'Switch to Premium': 'The reference shows Premium at ₹3,200/month. No subscription change or charge is made.',
      'Switch to Pro': 'The reference shows Pro at ₹9,100/month. No subscription change or charge is made.',
      'Add workflow slot': 'The example displays an extra workflow slot at ₹500/month. No purchase is made.',
      'Add agent seat': 'The example displays an extra agent seat at ₹500/month. No purchase is made.',
    };
    info(action, descriptions[action] ?? 'This is a demo-only action.');
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xF7FFFFFF), Color(0xCBFFFFFF)]),
      border: Border.all(color: const Color(0xEAFFFFFF)),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Color(0x0C181727), blurRadius: 18, offset: Offset(0, 5))],
    ),
    child: child,
  );
}

class DemoConversation extends StatefulWidget {
  final DemoChat chat;
  const DemoConversation({super.key, required this.chat});
  @override
  State<DemoConversation> createState() => _DemoConversationState();
}

class _DemoConversationState extends State<DemoConversation> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final List<String> sent = [];
  @override
  void dispose() {input.dispose(); scroll.dispose(); super.dispose();}

  void send() {
    final msg = input.text.trim();
    if (msg.isEmpty) return;
    setState(() => sent.add(msg));
    input.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preview only — no WhatsApp message was sent.'),
      duration: Duration(seconds: 2)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180), curve: Curves.easeOut);
    });
  }

  Widget bubble(String message, bool me, String timestamp) => Align(
    alignment: me ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(constraints: const BoxConstraints(maxWidth: 295),
      margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: me ? const Color(0xFFDBF8E4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x09000000), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Align(alignment: Alignment.centerLeft,
          child: Text(message, style: const TextStyle(color: ink, fontSize: 12.5, height: 1.45))),
        const SizedBox(height: 6),
        Text(timestamp, style: const TextStyle(color: muted, fontSize: 9)),
      ]),
    ));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white,
      titleSpacing: 2, elevation: 0,
      title: Row(children: [
        Container(width: 33, height: 33, alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFE8E6F1), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.person, color: navy, size: 22)),
        const SizedBox(width: 9),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.chat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
          const Text('Demo conversation', style: TextStyle(fontSize: 10, color: muted)),
        ]),
      ])),
    body: SafeArea(child: Column(children: [
      Expanded(child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(17, 23, 17, 10), children: [
        bubble(widget.chat.preview, false, '10:32 AM'),
        bubble('Hi! Thanks for contacting us. How can we help?', true, '10:33 AM · Demo'),
        for (final s in sent) bubble(s, true, 'Preview only · Not sent'),
      ])),
      Container(padding: const EdgeInsets.fromLTRB(12, 9, 12, 10), color: Colors.white,
        child: Row(children: [
          Expanded(child: TextField(controller: input, onSubmitted: (_) => send(),
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(hintText: 'Type a demo reply…',
              hintStyle: const TextStyle(fontSize: 12, color: muted),
              filled: true, fillColor: canvas,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(23), borderSide: BorderSide.none)))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: send, icon: const Icon(Icons.send_rounded, size: 20),
            style: IconButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white)),
        ])),
    ])),
  );
}
