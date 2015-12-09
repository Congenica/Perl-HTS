#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stdlib.h>
#include "tbx.h"
#include "kseq.h"

typedef htsFile*         Bio__HTS__File;
typedef tbx_t*           Bio__HTS__Tabix;
typedef hts_itr_t*       Bio__HTS__Tabix__Iterator;

MODULE = Bio::HTS PACKAGE = Bio::HTS::File PREFIX = htsfile_

htsFile*
htsfile_hts_open(fname)
    char *fname
  CODE:
    RETVAL = hts_open(fname, "r");
    if ( RETVAL == NULL )
        croak("Error: could not open file %s", fname);
  OUTPUT:
    RETVAL

int
htsfile_hts_close(file)
    htsFile* file
  CODE:
    RETVAL = hts_close(file);
    if ( RETVAL != 0 )
        croak("Error: could not close specified file");
  OUTPUT:
    RETVAL


MODULE = Bio::HTS PACKAGE = Bio::HTS::Tabix PREFIX = tabix_

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

MODULE = Bio::HTS PACKAGE = Bio::HTS::Tabix::Iterator PREFIX = tabix_

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
