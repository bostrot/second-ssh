library second_ssh.analytics;

import 'package:plausible_analytics/plausible_analytics.dart';

String analyticsUrl = "https://analytics.bostrot.com";
const String analyticsName = "secondssh.bostrot.com";

// TODO: remove '
Plausible plausible = Plausible(analyticsUrl, analyticsName);
