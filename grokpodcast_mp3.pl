use common::sense;
use Web::Scraper;
use Parallel::ForkManager;
use LWP::Simple qw/getstore/;

my $items = scraper{
    process "div.post", "posts[]" => scraper{
        process "a.podpress_downloadlink", "link" => '@href';
    };
};

my $fork = Parallel::ForkManager->new(15);

for (1 .. 9){
    my $res = $items->scrape( URI->new("http://grokpodcast.com/page/$_") );
    for my $post (@{$res->{posts}}) {
        my ($file) = ($post->{link} =~ /\/grokpodcast-(.*)$/);
        $file = "grokpodcast/$file";
        next if -f $file;
      $fork->start and next;
        say "Downloading... $file";
        getstore( $post->{link}, $file );
        say "Downloaded $file";
      $fork->finish;
    }
}

$fork->wait_all_children;
