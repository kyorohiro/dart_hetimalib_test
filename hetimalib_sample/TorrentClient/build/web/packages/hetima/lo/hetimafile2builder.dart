part of hetima;

class HetimaFileToBuilder extends HetimaBuilder {

  HetimaFile mFile;

  HetimaFileToBuilder(HetimaFile f) {
    mFile = f;
  }

  @override
  async.Future<List<int>> getByteFuture(int index, int length) {
    async.Completer<List<int>> c = new async.Completer();
    mFile.read(index, index+length).then((ReadResult r) {
      if(r.status == ReadResult.OK) {
        c.complete(r.buffer.toList());
      } else {
        throw new Error();
      }
    }).catchError((e){
      c.completeError(e);
    });
    return c.future;
  }

  @override
  async.Future<int> getLength() {
    return mFile.getLength();
  }
}
