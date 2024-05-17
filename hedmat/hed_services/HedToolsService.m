classdef HedToolsService < HedToolsBase
    % Creates a connection object for the HED web online services.
    
    properties
        ServicesUrl
        WebOptions
        HedVersion
        Cookie
        CSRFToken
    end
    
    methods
        function obj = HedToolsService(hedversion, host)
            % Construct a HedConnection that can be used for web services.
            %
            % Parameters:
            %  hedversion - valid version specification
            %  host - string or char array with the host name of service
            %
            %  Note, the version could be an array.
            obj.HedVersion = hedversion;
            obj.setSessionInfo(host);
        end

        function [] = resetHedVersion(obj, hedversion)
             obj.HedVersion = version;
        end

            
        function [] = setSessionInfo(obj, host)
            %% Setup the session for accessing the HED webservices
            %  Parameters:
            %      host  = URL for the services
            %
            %  Notes:  sets obj.cookie, obj.csrftoken and obj.optons.
            obj.ServicesUrl = [host '/services_submit'];
            request = matlab.net.http.RequestMessage;
            uri = matlab.net.URI([host '/services']);
            response1 = send(request,uri);
            cookies = response1.getFields('Set-Cookie');
            obj.Cookie = cookies.Value;
            data = response1.Body.char;
            csrfIdx = strfind(data,'csrf_token');
            tmp = data(csrfIdx(1)+length('csrf_token')+1:end);
            csrftoken = regexp(tmp,'".*?"','match');
            obj.CSRFToken = string(csrftoken{1}(2:end-1));
            header = ["Content-Type" "application/json"; ...
                "Accept" "application/json"; ...
                "X-CSRFToken" obj.CSRFToken; "Cookie" obj.Cookie];

            obj.WebOptions = weboptions('MediaType', 'application/json', ...
                'Timeout', 120, 'HeaderFields', header);

        end

        
        function issue_string = validate_hedtags(obj, hedtags, check_warnings)
            % Validate a single string of HED tags 
            request = obj.getRequestTemplate();
            request.service = 'strings_validate';
            request.schema_version = obj.HedVersion;
            if ~ischar(hedtags) && ~isstring(hedtags)
                throw(MException('HedToolsService:validate_hedtags', ...
                    'Must provide a string or char array as input'))
               
            end
            request.string_list = {hedtags};
            request.check_for_warnings = check_warnings;
            response = webwrite(obj.ServicesUrl, request, obj.WebOptions);
            response = jsondecode(response);
            error_msg = HedToolsService.getResponseError(response);
            if error_msg
                throw(MException(...
                    'HedToolsService:UnableToValidateString', error_msg));
            end
            if strcmpi(response.results.msg_category, 'warning')
                issue_string = response.results.data;
            else
                issue_string = '';
            end    
        end

        function issue_string = validate_sidecar(obj, sidecar, ...
                input_type, check_warnings)
            request = obj.getRequestTemplate();
            request.service = 'sidecar_validate';
            request.schema_version = obj.HedVersion;
            if ~ischar(hedtags) && ~isstring(hedtags)
                throw(MException('HedToolsService:validate_hedtags', ...
                    'Must provide a string or char array as input'))
               
            end
            request.string_string = ;
            request.check_for_warnings = check_warnings;
            response = webwrite(obj.ServicesUrl, request, obj.WebOptions);
            response = jsondecode(response);
            error_msg = HedToolsService.getResponseError(response);
            if error_msg
                throw(MException('HedService:UnableValidateSidecar', ...
                    error_msg));
            end
            if strcmpi(response.results.msg_category, 'warning')
                issue_string = response.results.data;
            else
                issue_string = '';
            end    
        end
    end

    methods (Static)
        function request = getRequestTemplate()
            % Create a parameter template for HEDTools web service request.

            request = struct('service', '', ...
                'schema_version', '', ...
                'schema_url', '', ...
                'schema_string', '', ...
                'sidecar_string', '', ...
                'events_string', '', ...
                'spreadsheet_string', '', ...
                'remodel_string', '', ...
                'columns_categorical', '', ...
                'columns_value', '', ...
                'tag_columns', '', ...
                'queries', '', ...
                'query_names', '', ...
                'remove_types', '', ...
                'check_for_warnings', false, ...
                'expand_context', true, ...
                'expand_defs', false, ...
                'include_summaries', false, ...
                'include_descriptions', true, ...
                'replace_defs', false);
        end

        function msg = getResponseError(response)
            if ~isempty(response.error_type)
                msg = sprintf('%s error %s: %s', response.service, ...
                    response.error_type, response.error_msg);
            else
                msg = '';
            end
        end
    end


end

