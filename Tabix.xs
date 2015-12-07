#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdlib.h>
#include "tbx.h"
#include "kseq.h"

MODULE = Tabix PACKAGE = HTSFile PREFIX = htsfile_

htsFile*
htsfile_hts_open(fname)
    char *fname
  CODE:
    RETVAL = hts_open(fname, "r");
  OUTPUT:
    RETVAL

void
htsfile_hts_close(file)
    htsFile* file
  CODE:
    hts_close(file);


MODULE = Tabix PACKAGE = Tabix PREFIX = tabix_

tbx_t* 
tabix_tbx_open(fname)
    char *fname
  CODE:
    RETVAL = tbx_index_load(fname);
  OUTPUT:
    RETVAL

void
tabix_tbx_close(t)
    tbx_t* t
  CODE:
    tbx_destroy(t);

hts_itr_t*
tabix_tbx_query(t, region)
    tbx_t* t
    char *region
  CODE:
    RETVAL = tbx_itr_querys(t, region);
  OUTPUT:
    RETVAL

#this must be called before reading any lines or it will break.
#i can't easily use ftell on fp and I can't be bothered to untangle it. just use it properly
SV*
tabix_tbx_header(fp, tabix)
    htsFile* fp
    tbx_t* tabix
  PREINIT:
    int num_header_lines = 0;
    AV *av_ref;
    kstring_t str = {0,0,0};
  CODE:
    av_ref = newAV();
    while ( hts_getline(fp, KS_SEP_LINE, &str) >= 0 ) {
        if ( ! str.l ) break; //no lines left so we are done
        if ( str.s[0] != tabix->conf.meta_char ) break;

        //the line begins with a # so add it to the array
        ++num_header_lines;
        av_push(av_ref, newSVpv(str.s, str.l));
    }

    if ( ! num_header_lines )
        XSRETURN_EMPTY;

    RETVAL = newRV_noinc((SV*) av_ref);
  OUTPUT:
    RETVAL

SV*
tabix_tbx_seqnames(t)
    tbx_t* t
  PREINIT:
    const char **names;
    int i, num_seqs;
    AV *av_ref;
  CODE:
    names = tbx_seqnames(t, &num_seqs); //call actual tabix method

    //blast all the values onto a perl array
    av_ref = newAV();
    for (i = 0; i < num_seqs; ++i) {
        SV *sv_ref = newSVpv(names[i], 0);
        av_push(av_ref, sv_ref);
    }

    free(names);

    //return a reference to our array
    RETVAL = newRV_noinc((SV*)av_ref); 
  OUTPUT:
    RETVAL

MODULE = Tabix PACKAGE = TabixIterator PREFIX = tabix_

SV*
tabix_tbx_iter_next(iter, fp, t)
    hts_itr_t* iter
    htsFile* fp
    tbx_t* t
  PREINIT:
    kstring_t str = {0,0,0};
  CODE:
    if (tbx_itr_next(fp, t, iter, &str) < 0)
        XSRETURN_EMPTY;

    RETVAL = newSVpv(str.s, str.l);
  OUTPUT:
    RETVAL

void
tabix_tbx_iter_free(iter)
	hts_itr_t* iter
  CODE:
	tbx_itr_destroy(iter);
