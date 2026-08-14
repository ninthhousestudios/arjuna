// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

/// Chart-RDF serializer + deterministic IRI minter for Arrow (ARP-4).
///
/// (OACF chart + view config) -> N-Quads, conforming to vidya's chart ontology
/// (the upstream contract). Tracer scope: Chart identity + one placements View.
library;

export 'src/canon_iri.dart';
export 'src/chart_computer.dart';
export 'src/chart_identity.dart';
export 'src/computed_view.dart';
export 'src/ephe_path.dart';
export 'src/iri.dart';
export 'src/iri_minter.dart';
export 'src/nquads.dart';
export 'src/rdf_term.dart';
export 'src/serializer.dart';
export 'src/view_spec.dart';
