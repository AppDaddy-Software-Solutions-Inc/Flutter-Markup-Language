// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
import 'package:fml/datasources/http/http.dart';
import 'package:fml/log/manager.dart';
import 'package:path/path.dart';
import 'asset.dart';
import 'package:fml/helper/helper_barrel.dart';

// platform
import 'package:fml/platform/platform.stub.dart'
if (dart.library.io)   'package:fml/platform/platform.vm.dart'
if (dart.library.html) 'package:fml/platform/platform.web.dart';

class Mirror
{
  final String? domain;
  final String? mirrorApi;
  Mirror(this.domain, this.mirrorApi);

  bool abort = false;

  void dispose()
  {
    abort = true;
  }

  void execute() async
  {
    if (S.isNullOrEmpty(mirrorApi)) return;

    // load assets
    Assets assets = Assets();
    await assets.loadAssetFromServer(mirrorApi!);

    for (Asset asset in assets.list)
    if (asset.type == "file" && !abort)
    {
      var uri = Url.parse(asset.uri);
      String? filename = uri?.page;
      if (filename != null && extension(filename).trim() != "")
      {
        // file exists?
        bool exists = Platform.fileExists(filename);

        // check the age
        bool downloadRequired = true;
        if (exists)
        {
          var file = Platform.getFile(filename);
          if (file != null)
          {
            var modified = await file.lastModified();
            var epoch = modified.millisecondsSinceEpoch;
            if (epoch >= (asset.epoch ?? 0)) downloadRequired = false;
            if (downloadRequired) Log().debug('File on disk is out of date [${asset.name}]', caller: "Mirror");
          }
        }

        // get the asset from the server
        if (downloadRequired && !abort) await _copyAssetFromServer(asset, asset.uri, domain);
      }
    }

    Log().debug('Inventory Check Complete', caller: "Mirror");
  }

  static Future<bool> _copyAssetFromServer(Asset asset, String? path, String? domain) async
  {
    if (asset.uri != null)
    {
      Log().debug('Getting file from server [${asset.name}]', caller: "Mirror");

      // query the asset
      var response = await Http.get(asset.uri!);

      // error in response?
      if (!response.ok)
      {
        Log().error('Error copying asset from ${asset.uri}. Error is ${response.statusMessage}', caller: "Mirror");
        return false;
      }

      // write asset to disk
      var uri = Url.parse(asset.uri);
      String? filename = uri?.page;
      if (filename != null)
      {
        Log().debug('Writing file to disk $filename', caller: "Mirror");
        await Platform.writeFile(filename, response.bytes);
        return true;
      }
      return false;
    }
    else return false;
  }
}
