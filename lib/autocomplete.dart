library atom.autocomplete_impl;

import 'dart:async';

import 'package:logging/logging.dart';

import 'analysis/analysis_server_lib.dart' show CompletionResults,
    CompletionSuggestion, SuggestionsResult;
import 'atom.dart';
import 'atom_autocomplete.dart';
import 'state.dart';
import 'utils.dart';

part 'autocomplete/dart_autocomplete_provider.dart';

final Logger _logger = new Logger('autocomplete');
