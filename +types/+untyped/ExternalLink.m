classdef ExternalLink < handle
    properties(SetAccess=private)
        stub;
    end
    
    properties(Dependent)
        filename;
        path;
    end
    
    methods
        function obj = ExternalLink(filename, path)
            obj.stub = types.untyped.DataStub(filename, path);
        end
        
        function data = deref(obj)
            data = obj.stub.load();
        end
        
        function refs = export(obj, fid, fullpath, refs)
            plist = 'H5P_DEFAULT';
            H5L.create_external(obj.filename, obj.path, fid, fullpath, plist, plist);
        end
        
        function fnm = get.filename(obj)
            fnm = obj.stub.filename;
        end
        
        function path = get.path(obj)
            path = obj.stub.path;
        end
    end
end