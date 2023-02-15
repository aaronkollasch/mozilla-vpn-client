// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

//! Copied from: https://searchfox.org/mozilla-central/source/toolkit/components/glean/api/src/ffi/macros.rs

/// Get a metric object by id from the corresponding map, then
/// execute the provided closure with it.
///
/// Ignores the possibility that the $id might be for a labeled submetric.
///
/// # Arguments
///
/// * `$map` - The name of the hash map within `metrics::__generated_metrics`
///            (or `factory::__jog_metric_maps`)
///            as generated by glean_parser.
/// * `$id`  - The ID of the metric to get.
/// * `$m`   - The identifier to use for the retrieved metric.
///            The expression `$f` can use this identifier.
/// * `$f`   - The expression to execute with the retrieved metric `$m`.
macro_rules! with_metric {
    ($map:ident, $id:ident, $m:ident, $f:expr) => {
        match $crate::metrics::__generated_metrics::$map.get(&$id.into()) {
            Some($m) => $f,
            None => panic!("No metric for id {}", $id),
        }
    };
}
