function issue_string = validate_bids(data_root)
% Validate the HED annotations in a BIDS dataset.
% 
% Parameters:
%    data_root  - Full path to the root directory of a BIDS dataset.
%
% Returns:
%     issue_string - A string with the validation issues suitable for
%                   printing (has newlines).
%
    hed = py.importlib.import_module('hed')
    % amod = py.importlib.import_module('hed.tools.analysis.annotation_util');
    bids = hed.get_bids_dataset(data_root);
    issues = bids.validate();
    issue_string = string(py.hed.get_printable_issue_string(issues));