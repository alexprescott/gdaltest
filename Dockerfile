FROM gcc:4.9 AS build

COPY . /usr/src/gdaltest
WORKDIR /usr/src/gdaltest

RUN apt-get update && apt-get install -y libgdal-dev gcc-4.9-locales g++-4.9-multilib libstdc++6-4.9-dbg gcc-4.9-multilib libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg libasan1-dbg liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libquadmath0-dbg libgdal-doc libhdf4-doc hdf4-tools libhdf5-doc icu-doc netcdf-bin netcdf-doc libmyodbc odbc-postgresql tdsodbc unixodbc-bin ogdi-bin libstdc++-4.9-doc libxerces-c-doc poppler-utils ghostscript

ENV C_INCLUDE_PATH=/usr/include/gdal

RUN gcc -o a.exe calcStats.c -lm -lgdal

RUN mkdir -p /tmp/fakeroot/lib  && \
        cp $(ldd a.exe | grep -o '/.\+\.so[^ ]*' | sort | uniq) /tmp/fakeroot/lib && \
        for lib in /tmp/fakeroot/lib/*; do strip --strip-all $lib; done


FROM ubuntu
WORKDIR /usr/src/gdaltest

COPY --from=build /tmp/fakeroot /
COPY --from=build /usr/src/gdaltest /usr/src/gdaltest

CMD ./a.exe
 
